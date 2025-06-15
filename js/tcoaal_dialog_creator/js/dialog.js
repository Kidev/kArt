class DialogFramework {
    constructor() {
        this.scenes = [];
        this.currentScene = 0;
        this.isTyping = false;
        this.typeSpeed = 20; // Faster and smoother - milliseconds per character
        this.currentText = '';
        this.typingTimeout = null;

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
        this.updateDebugInfo();
    }

    // Add a scene to the timeline
    addScene(options) {
        const scene = {
            delay: options.delay || 0,        // Delay between image and text
            image: options.image || null,
            speaker: options.speaker || '',   // Empty string for narrator
            text: options.text || '',
            fade: options.fade !== undefined ? options.fade : true  // Default to fade
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

        // Show image first if specified
        if (scene.image) {
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
                this.showDialog(scene.speaker, scene.text);
                await this.fadeInDialog();
            } else {
                // Keep dialog box, just replace text
                this.showDialog(scene.speaker, scene.text, false);
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

    // Show dialog with typewriter effect
    showDialog(speaker, text, showContainer = true) {
        const dialogContainer = document.getElementById('dialogContainer');
        const speakerLine = document.getElementById('speakerLine');
        const textLine1 = document.getElementById('textLine1');
        const textLine2 = document.getElementById('textLine2');

        // Clear previous content and styles
        speakerLine.className = 'dialog-line speaker-line';
        speakerLine.textContent = '';
        textLine1.textContent = '';
        textLine2.textContent = '';

        // Set speaker info (Line 1)
        if (speaker && this.characters[speaker]) {
            speakerLine.textContent = speaker;
            speakerLine.classList.add(this.characters[speaker].class);
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
            dialogContainer.style.opacity = '0';
            await this.wait(500); // Wait for fade transition
            dialogContainer.classList.remove('active');
            dialogContainer.style.opacity = '1';
        }
    }

    // Fade in dialog
    async fadeInDialog() {
        const dialogContainer = document.getElementById('dialogContainer');
        dialogContainer.style.opacity = '0';
        dialogContainer.classList.add('active');
        await this.wait(50); // Small delay for DOM update
        dialogContainer.style.opacity = '1';
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

    // Typewriter effect for multiple lines (letter by letter)
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
