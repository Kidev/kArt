class GlitchTextEffect {
    constructor(element, config = {}) {
        this.element = element;
        this.originalText = '';
        this.characters = [];
        this.intervals = [];
        this.isRunning = false;
        this.isRevealed = false;
        
        // Configuration
        this.config = {
            scrambledColor: config.scrambledColor || '#ff4444',
            realColor: config.realColor || '#44ff44',
            changeSpeed: config.changeSpeed || 150,
            realProbability: config.realProbability || 15,
            autoStart: config.autoStart !== undefined ? config.autoStart : true
        };

        // Character sets for scrambling
        this.scrambleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()[]{}|\\:";\'<>?,./`~';
        
        if (this.element && this.element.textContent) {
            this.setText(this.element.textContent);
            if (this.config.autoStart) {
                this.start();
            }
        }
    }

    setText(text) {
        this.originalText = text;
        this.setupCharacters();
    }

    setupCharacters() {
        if (!this.element) return;
        
        this.element.innerHTML = '';
        this.characters = [];

        for (let i = 0; i < this.originalText.length; i++) {
            const char = this.originalText[i];
            const span = document.createElement('span');
            span.className = 'glitch-char';
            span.textContent = char === ' ' ? '\u00A0' : char;
            span.style.color = this.config.scrambledColor;
            span.style.display = 'inline-block';
            span.style.fontFamily = 'monospace';
            span.style.width = '1ch'; // Fixed character width
            span.style.textAlign = 'center';
            
            this.element.appendChild(span);
            this.characters.push({
                element: span,
                originalChar: char,
                currentChar: char
            });
        }
    }

    getRandomChar() {
        return this.scrambleChars[Math.floor(Math.random() * this.scrambleChars.length)];
    }

    shouldShowReal() {
        return Math.random() * 100 < this.config.realProbability;
    }

    updateCharacter(charObj) {
        if (charObj.originalChar === ' ') {
            return;
        }

        if (this.isRevealed || this.shouldShowReal()) {
            charObj.currentChar = charObj.originalChar;
            charObj.element.textContent = charObj.originalChar;
            charObj.element.style.color = this.config.realColor;
        } else {
            charObj.currentChar = this.getRandomChar();
            charObj.element.textContent = charObj.currentChar;
            charObj.element.style.color = this.config.scrambledColor;
        }
    }

    start() {
        if (this.isRunning) {
            this.stop();
        }

        this.isRunning = true;
        this.isRevealed = false;

        this.characters.forEach((charObj, index) => {
            if (charObj.originalChar !== ' ') {
                const interval = setInterval(() => {
                    if (this.isRunning) {
                        this.updateCharacter(charObj);
                    }
                }, this.config.changeSpeed + (Math.random() * 50));

                this.intervals.push(interval);
            }
        });
    }

    stop() {
        this.isRunning = false;
        this.intervals.forEach(interval => clearInterval(interval));
        this.intervals = [];
    }

    reveal() {
        this.isRevealed = true;
        this.characters.forEach(charObj => {
            charObj.element.textContent = charObj.originalChar === ' ' ? '\u00A0' : charObj.originalChar;
            charObj.element.style.color = this.config.realColor;
        });
    }

    destroy() {
        this.stop();
        this.characters = [];
        if (this.element) {
            this.element.innerHTML = '';
        }
    }
}

class DialogFramework {
    constructor() {
        this.scenes = [];
        this.currentScene = 0;
        this.isTyping = false;
        this.typeSpeed = 20; // Faster and smoother - milliseconds per character
        this.currentText = '';
        this.typingTimeout = null;
        this.currentBackgroundImage = null; // Track current background image
        this.loadedSounds = new Map(); // Cache for loaded audio files
        this.glitchEffects = []; // Track all glitch effects for cleanup
        this.speakerGlitch = null; // Track speaker name glitch effect

        // Character definitions - only Ashley and Andrew for now
        this.characters = {
            'Andrew': {
                color: '#a6de7f',
                class: 'speaker-andrew'
            },
            'Ashley': {
                color: '#e2829a',
                class: 'speaker-ashley'
            }
        };

        this.initializeEventListeners();
        this.initializeAudio();
        this.updateDebugInfo();
    }

    // Initialize audio system using HTML5 Audio (works with local files)
    async initializeAudio() {
        try {
            // Test if we can create audio elements
            const testAudio = new Audio();
            console.log('HTML5 Audio initialized successfully');
        } catch (error) {
            console.warn('Audio not supported:', error);
        }
    }

    // Load and cache audio file using HTML5 Audio
    async loadSound(soundPath) {
        if (this.loadedSounds.has(soundPath)) {
            return this.loadedSounds.get(soundPath);
        }

        try {
            const audio = new Audio('sounds/' + soundPath);
            
            // Return a promise that resolves when audio can play
            return new Promise((resolve, reject) => {
                const onCanPlay = () => {
                    audio.removeEventListener('canplaythrough', onCanPlay);
                    audio.removeEventListener('error', onError);
                    this.loadedSounds.set(soundPath, audio);
                    resolve(audio);
                };
                
                const onError = (error) => {
                    audio.removeEventListener('canplaythrough', onCanPlay);
                    audio.removeEventListener('error', onError);
                    console.warn(`Failed to load sound: ${soundPath}`, error);
                    resolve(null); // Resolve with null instead of rejecting
                };

                audio.addEventListener('canplaythrough', onCanPlay);
                audio.addEventListener('error', onError);
                
                // Set a timeout to avoid hanging forever
                setTimeout(() => {
                    if (!this.loadedSounds.has(soundPath)) {
                        audio.removeEventListener('canplaythrough', onCanPlay);
                        audio.removeEventListener('error', onError);
                        console.warn(`Timeout loading sound: ${soundPath}`);
                        resolve(null);
                    }
                }, 5000);
            });
        } catch (error) {
            console.warn(`Failed to create audio for: ${soundPath}`, error);
            return null;
        }
    }

    // Play sound using HTML5 Audio
    async playSound(soundPath, volume = 1.0) {
        if (!soundPath) return;

        try {
            let audio = await this.loadSound(soundPath);
            
            if (!audio) {
                console.warn(`Could not load sound: ${soundPath}`);
                return;
            }

            // Clone the audio for multiple simultaneous plays
            const audioClone = audio.cloneNode();
            audioClone.volume = Math.max(0, Math.min(1, volume)); // Clamp volume between 0 and 1
            
            // Play the sound
            const playPromise = audioClone.play();
            
            if (playPromise !== undefined) {
                playPromise.catch(error => {
                    console.warn(`Failed to play sound: ${soundPath}`, error);
                });
            }
        } catch (error) {
            console.warn(`Error playing sound: ${soundPath}`, error);
        }
    }

    // Add a scene to the timeline
    addScene(options) {
        const scene = {
            delay: options.delay || 0,        // Delay between image and text
            image: options.image || null,
            speaker: options.speaker || '',   // Empty string for narrator
            text: options.text || '',
            fade: options.fade !== undefined ? options.fade : true,  // Default to fade
            sound: options.sound || null,     // Sound file to play
            soundVolume: options.soundVolume || 1.0,  // Sound volume (0.0 to 1.0)
            soundDelay: options.soundDelay || 0,       // Delay before playing sound (milliseconds)
            censorSpeaker: options.censorSpeaker !== undefined ? options.censorSpeaker : true  // Whether to apply glitch to speaker name
        };
        this.scenes.push(scene);
        this.updateDebugInfo();
        return this;
    }

    // Initialize event listeners
    initializeEventListeners() {
        document.addEventListener('keydown', (e) => {
            if (e.code === 'Space') {
                e.preventDefault();
                if (this.isTyping) {
                    this.skipText();
                } else {
                    this.next();
                }
            }
        });

        // Click to advance
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.controls')) {
                if (this.isTyping) {
                    this.skipText();
                } else {
                    this.next();
                }
            }
        });
    }

    // Start the dialog sequence
    start() {
        this.currentScene = 0;
        this.showScene(0);
    }

    // Show a specific scene
    async showScene(index) {
        if (index >= this.scenes.length) {
            console.log('No more scenes');
            this.hideDialog();
            return;
        }

        const scene = this.scenes[index];

        // Schedule sound playback with delay if specified
        if (scene.sound) {
            if (scene.soundDelay > 0) {
                setTimeout(() => {
                    this.playSound(scene.sound, scene.soundVolume);
                }, scene.soundDelay);
            } else {
                this.playSound(scene.sound, scene.soundVolume);
            }
        }

        // Show image first if specified and different from current
        if (scene.image && scene.image !== this.currentBackgroundImage) {
            this.showImage(scene.image);
        }

        // Wait for delay between image and text
        if (scene.delay > 0) {
            await this.wait(scene.delay);
        }

        // Handle dialog display
        if (scene.text.trim()) {
            if (scene.fade) {
                // Fade out current dialog, then fade in new one
                await this.fadeOutDialog();
                this.showDialog(scene.speaker, scene.text, true, scene.censorSpeaker);
                await this.fadeInDialog();
            } else {
                // Keep dialog box, just replace text
                this.showDialog(scene.speaker, scene.text, false, scene.censorSpeaker);
            }
        } else {
            // If no text, hide dialog
            if (scene.fade) {
                await this.fadeOutDialog();
            } else {
                this.hideDialog();
            }
        }

        this.updateDebugInfo();
    }

    // Show background image with fade transition
    showImage(imageSrc) {
        // Update current background image tracker
        this.currentBackgroundImage = imageSrc;

        // Remove existing active images
        const existingImages = document.querySelectorAll('.background-image.active');
        existingImages.forEach(img => img.classList.remove('active'));

        // Create new image element
        const img = document.createElement('img');
        img.src = 'img/' + imageSrc;
        img.className = 'background-image';
        img.onload = () => {
            img.classList.add('active');
        };

        img.onerror = () => {
            console.warn(`Failed to load image: ${imageSrc}`);
        };

        document.querySelector('.game-container').appendChild(img);

        // Clean up old images after transition
        setTimeout(() => {
            existingImages.forEach(img => img.remove());
        }, 1100);
    }

    // Parse HTML-like tags and apply formatting
    parseFormattedText(text) {
        // Create a temporary div to parse the text
        const tempDiv = document.createElement('div');
        
        // Replace custom tags with HTML equivalents
        let formattedText = text
            .replace(/<b>/g, '<strong>')
            .replace(/<\/b>/g, '</strong>')
            .replace(/<i>/g, '<em>')
            .replace(/<\/i>/g, '</em>')
            .replace(/<u>/g, '<span style="text-decoration: underline;">')
            .replace(/<\/u>/g, '</span>');
        
        // Handle glitch tags separately
        const glitchRegex = /<glitch([^>]*)>(.*?)<\/glitch>/g;
        let match;
        let glitchCounter = 0;
        
        while ((match = glitchRegex.exec(formattedText)) !== null) {
            const attributes = match[1];
            const glitchText = match[2];
            const glitchId = `glitch-${Date.now()}-${glitchCounter++}`;
            
            // Parse glitch attributes (optional)
            let glitchConfig = {
                scrambledColor: '#ff4444',
                realColor: '#44ff44',
                changeSpeed: 150,
                realProbability: 15
            };
            
            // Simple attribute parsing
            if (attributes) {
                const colorMatch = attributes.match(/color="([^"]+)"/);
                if (colorMatch) glitchConfig.realColor = colorMatch[1];
                
                const scrambledMatch = attributes.match(/scrambled="([^"]+)"/);
                if (scrambledMatch) glitchConfig.scrambledColor = scrambledMatch[1];
                
                const speedMatch = attributes.match(/speed="([^"]+)"/);
                if (speedMatch) glitchConfig.changeSpeed = parseInt(speedMatch[1]);
            }
            
            formattedText = formattedText.replace(match[0], `<span class="glitch-container" data-glitch-id="${glitchId}" data-glitch-config='${JSON.stringify(glitchConfig)}'>${glitchText}</span>`);
        }
        
        tempDiv.innerHTML = formattedText;
        return tempDiv;
    }

    // Apply glitch effects to parsed elements
    applyGlitchEffects(container) {
        const glitchContainers = container.querySelectorAll('.glitch-container');
        
        glitchContainers.forEach(glitchContainer => {
            const config = JSON.parse(glitchContainer.dataset.glitchConfig);
            const glitchEffect = new GlitchTextEffect(glitchContainer, config);
            this.glitchEffects.push(glitchEffect);
        });
    }

    // Clean up all glitch effects
    cleanupGlitchEffects() {
        this.glitchEffects.forEach(effect => effect.destroy());
        this.glitchEffects = [];
        
        if (this.speakerGlitch) {
            this.speakerGlitch.destroy();
            this.speakerGlitch = null;
        }
    }

    // Show dialog with typewriter effect and formatting support
    showDialog(speaker, text, showContainer = true, censorSpeaker = true) {
        const dialogContainer = document.getElementById('dialogContainer');
        const speakerLine = document.getElementById('speakerLine');
        const textLine1 = document.getElementById('textLine1');
        const textLine2 = document.getElementById('textLine2');

        // Clean up previous glitch effects
        this.cleanupGlitchEffects();

        // Clear previous content and styles
        speakerLine.className = 'dialog-line speaker-line';
        speakerLine.innerHTML = '';
        textLine1.innerHTML = '';
        textLine2.innerHTML = '';

        // Set speaker info (Line 1) with optional glitch effect
        if (speaker && this.characters[speaker]) {
            speakerLine.textContent = speaker;
            speakerLine.classList.add(this.characters[speaker].class);
            
            // Apply glitch effect to speaker name only if censorSpeaker is true
            if (censorSpeaker) {
                this.speakerGlitch = new GlitchTextEffect(speakerLine, {
                    scrambledColor: '#ff4444', // Red for error
                    realColor: this.characters[speaker].color,
                    changeSpeed: 120,
                    realProbability: 20,
                    autoStart: true
                });
            }
        }

        // Prepare text with quotes for characters, no quotes for narrator
        let finalText = text;
        if (speaker && this.characters[speaker]) {
            finalText = `"${text}"`;
        }

        // Split text into lines that fit the dialog box
        const textLines = this.wrapTextToLines(finalText, 2); // 2 lines available for text

        // Show dialog container if needed
        if (showContainer) {
            dialogContainer.classList.add('active');
        }

        // Start typewriter effect for each line
        this.typeTextLines([textLine1, textLine2], textLines);
    }

    // Fade out dialog
    async fadeOutDialog() {
        const dialogContainer = document.getElementById('dialogContainer');
        if (dialogContainer.classList.contains('active')) {
            dialogContainer.classList.remove('active');
            await this.wait(500); // Wait for fade transition
        }
    }

    // Fade in dialog
    async fadeInDialog() {
        const dialogContainer = document.getElementById('dialogContainer');
        dialogContainer.classList.add('active');
        await this.wait(500); // Wait for fade in
    }

    // Wrap text to fit in specified number of lines
    wrapTextToLines(text, maxLines) {
        const words = text.split(' ');
        const lines = [];
        let currentLine = '';
        const maxCharsPerLine = 75; // Slightly more chars per line with 2 lines

        for (const word of words) {
            const testLine = currentLine + (currentLine ? ' ' : '') + word;

            if (testLine.length <= maxCharsPerLine) {
                currentLine = testLine;
            } else {
                if (currentLine) {
                    lines.push(currentLine);
                    currentLine = word;
                } else {
                    // Word is too long, split it
                    lines.push(word.substring(0, maxCharsPerLine));
                    currentLine = word.substring(maxCharsPerLine);
                }

                if (lines.length >= maxLines) {
                    break;
                }
            }
        }

        if (currentLine && lines.length < maxLines) {
            lines.push(currentLine);
        }

        // Pad with empty strings if needed
        while (lines.length < maxLines) {
            lines.push('');
        }

        return lines.slice(0, maxLines);
    }

    // Typewriter effect for multiple lines (letter by letter) - main method
    async typeTextLines(elements, textLines) {
        this.isTyping = true;
        this.currentText = textLines.join(' ');

        for (let lineIndex = 0; lineIndex < elements.length; lineIndex++) {
            const element = elements[lineIndex];
            const text = textLines[lineIndex] || '';

            if (!text) continue;

            element.textContent = '';

            for (let i = 0; i < text.length; i++) {
                if (!this.isTyping) break;

                element.textContent += text[i];
                await this.wait(this.typeSpeed);
            }

            if (!this.isTyping) break;
        }

        this.isTyping = false;
    }

    // Typewriter text effect
    async typeText(element, text) {
        this.isTyping = true;
        this.currentText = text;
        element.textContent = '';

        for (let i = 0; i < text.length; i++) {
            if (!this.isTyping) break; // Allow skipping

            element.textContent += text[i];
            await this.wait(this.typeSpeed);
        }

        this.isTyping = false;
    }

    // Skip current typing animation
    skipText() {
        if (this.isTyping) {
            this.isTyping = false;

            // Get the text lines and display them immediately
            const textLine1 = document.getElementById('textLine1');
            const textLine2 = document.getElementById('textLine2');

            // Find current scene and reconstruct the text
            if (this.currentScene < this.scenes.length) {
                const scene = this.scenes[this.currentScene];
                let finalText = scene.text;

                if (scene.speaker && this.characters[scene.speaker]) {
                    finalText = `"${scene.text}"`;
                }

                const textLines = this.wrapTextToLines(finalText, 2);

                textLine1.textContent = textLines[0] || '';
                textLine2.textContent = textLines[1] || '';
            }
        }
    }

    // Move to next scene
    next() {
        if (this.isTyping) {
            this.skipText();
            return;
        }

        this.currentScene++;
        if (this.currentScene < this.scenes.length) {
            this.showScene(this.currentScene);
        } else {
            console.log('End of scenes');
            this.hideDialog();
        }
    }

    // Hide dialog
    hideDialog() {
        const dialogContainer = document.getElementById('dialogContainer');
        dialogContainer.classList.remove('active');
    }

    // Reset to beginning
    reset() {
        this.currentScene = 0;
        this.isTyping = false;
        this.currentBackgroundImage = null; // Reset image tracker
        this.cleanupGlitchEffects(); // Clean up glitch effects
        this.hideDialog();

        // Remove all images
        const images = document.querySelectorAll('.background-image');
        images.forEach(img => img.remove());

        this.updateDebugInfo();
    }

    // Utility function for delays
    wait(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Update debug information
    updateDebugInfo() {
        const debugInfo = document.getElementById('debugInfo');
        debugInfo.textContent = `Scene: ${this.currentScene + 1} / ${this.scenes.length}`;
    }

    // Set typing speed
    setTypeSpeed(speed) {
        this.typeSpeed = speed;
        return this;
    }

    // Get current scene index
    getCurrentScene() {
        return this.currentScene;
    }

    // Jump to specific scene
    jumpToScene(index) {
        if (index >= 0 && index < this.scenes.length) {
            this.currentScene = index;
            this.showScene(index);
        }
        return this;
    }
}

// Create global instance
const dialogFramework = new DialogFramework();