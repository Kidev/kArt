// sequence.js - Define your RPG dialog sequences here
// The setup function will be called automatically when the page loads

function setupScene() {
    dialogFramework
        .addScene({
            delay: 0,
            image: 'intro.png',
            speaker: '',
            text: '',
            sound: '',        // Play intro sound
            soundVolume: 0.8,          // 80% volume
            soundDelay: 500,
            fade: true
        })
        .addScene({
            delay: 1000,
            image: 'youre_andrew.png',
            speaker: '',
            text: 'You are Andrew!',
            sound: 'intro.mp3',        // Play intro sound
            soundVolume: 0.8,          // 80% volume
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: '',
            image: 'ashley_close.png',
            text: '',
            sound: '',       // Scene transition sound
            soundVolume: 0.6,
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: '',
            image: 'ashley_open.png',  // Different image - will fade
            text: '',
            sound: '',     // Eye opening sound effect
            fade: true
        })
        .addScene({
            delay: 1000,
            speaker: 'Andrew',
            image: 'guilty.png',
            text: 'I never knew what I was guilty of',
            sound: '', // Dialog sound
            soundVolume: 0.5,
            censorSpeaker: true,  // Speaker name will have glitch effect
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: 'Andrew',
            image: 'guilty.png',       // Same image - no fade transition!
            text: 'But I keep coming when you call <i>(coming when you call)</i>',
            sound: '',
            censorSpeaker: false,  // Speaker name will NOT have glitch effect
            fade: false                // Quick text change, no dialog fade
        })
        .addScene({
            delay: 1000,
            speaker: 'Ashley',
            image: 'ashley_response.png',
            text: 'You <b>always</b> do what I want.',
            sound: '',
            soundVolume: 0.7,
            censorSpeaker: true,   // Speaker name will have glitch effect
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: 'Ashley',
            image: 'ashley_response.png', // Same image again - optimized!
            text: 'That\'s why I <u>love</u> you, brother.',
            censorSpeaker: false,  // Speaker name will NOT have glitch effect  
            fade: false                 // No dialog box fade for quick response
        })
        .addScene({
            delay: 500,
            speaker: '',
            image: 'mystery.png',
            text: 'The <glitch>CENSORED DATA</glitch> was never meant to be seen.',
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: 'Ashley',
            text: 'What was that <glitch color="#ff00ff" scrambled="#ff0000" speed="100">strange noise</glitch>?',
            censorSpeaker: true,
            fade: false
        });
}

/*
 ENHANCED SCENE OPTIONS REFERENCE:

 delay: number (milliseconds)
 - Time to wait after image displays before showing text
 - Use 0 for immediate text, 1000+ for dramatic pauses

 image: string (file path)
 - Background image to display from 'img/' folder
 - OPTIMIZATION: If same as previous scene, no fade transition occurs
 - Optional - leave out to keep current background

 speaker: string ('Ashley', 'Andrew', or '')
 - 'Ashley' = pink colored name with quotes around text + optional glitch effect
 - 'Andrew' = green colored name with quotes around text + optional glitch effect
 - '' (empty) = narrator mode, no name shown, no quotes
 - Use censorSpeaker parameter to control glitch effect on character names

 censorSpeaker: boolean (true/false) - NEW!
 - true = Apply glitch effect to character name (red scrambled text)
 - false = Show character name normally without glitch effect
 - Default is true if not specified
 - Only affects character names, not dialog text

 text: string (with formatting support)
 - The dialog text to display
 - Automatically wraps to fit 2 lines (~75 chars per line)
 - Leave empty '' to show no dialog box
 - Supports HTML-like formatting tags:
   * <b>bold text</b> - Makes text bold
   * <i>italic text</i> - Makes text italic  
   * <u>underlined text</u> - Underlines text
   * <glitch>scrambled text</glitch> - Applies glitch censor effect
   * <glitch color="#00ff00" scrambled="#ff0000" speed="120">custom glitch</glitch>
     - color: Normal text color when revealed
     - scrambled: Color of scrambled characters
     - speed: Change speed in milliseconds

 fade: boolean (true/false)
 - true = smooth fade transitions for dialog box
 - false = instant text replacement (good for rapid exchanges)
 - Default is true if not specified

 sound: string (file path)
 - Sound file to play from 'sounds/' folder
 - Supports common formats: .mp3, .wav, .ogg
 - Optional - leave out for silent scenes
 - Examples: 'footstep.mp3', 'door_open.wav', 'music/bg_theme.ogg'

 soundVolume: number (0.0 to 1.0)
 - Volume level for the sound effect
 - 0.0 = silent, 1.0 = full volume
 - Default is 1.0 if not specified
 - Good for balancing different audio levels

 FORMATTING EXAMPLES:
 text: 'This is <b>bold</b> and <i>italic</i> text.'
 text: 'I <u>really</u> mean it!'
 text: 'The password is <glitch>SECRET123</glitch>.'
 text: 'Something <glitch color="#00ff00" scrambled="#ff0000">weird</glitch> happened.'

 SPEAKER CENSORING EXAMPLES:
 censorSpeaker: true   // Character name gets glitch effect (default)
 censorSpeaker: false  // Character name appears normally

 GLITCH EFFECT FEATURES:
 - Character names can have optional glitch effects (controlled by censorSpeaker)
 - Dialog text can have custom glitch effects with <glitch> tags
 - Glitch effects use monospace font for stable layout (no text jumping)
 - Each glitch effect runs independently and cleans up automatically
 - Formatting is applied after typewriter effect completes for smooth animation

 PERFORMANCE NOTES:
 - Images: Framework detects repeated images and skips fade animation
 - Audio: Sounds are cached after first load for better performance  
 - Dialog: Smooth typewriter animation with proper spacing
 - Glitch: Monospace font prevents layout shifting during character changes
 - Formatting: HTML tags are applied after typing completes for smooth animation
 
 FOLDER STRUCTURE:
 project/
 ├── img/           (background images)
 ├── sounds/        (audio files)
 ├── tcoaal.html
 ├── style.css
 ├── js/
 │   ├── dialog.js
 │   └── sequence.js
 └── fonts/

 COMMON SOUND TYPES:
 - Scene transitions: whoosh.mp3, fade_in.wav
 - Character voices: ashley_hmm.mp3, andrew_sigh.wav  
 - UI sounds: dialog_open.mp3, text_complete.wav
 - Ambient: rain.ogg, forest_ambience.mp3
 - Music: bg_tension.mp3, emotional_theme.ogg
*/