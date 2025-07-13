// sequence.js
// The setup function will be called automatically when the page loads
function setupScene() {

    dialogFramework
        .setConfig({
            showControls: false,
            showDebug: false
        });

    dialogFramework
        .setCharacters({
            'Andrew': {
                color: '#a6de7f'
            },
            'Ashley': {
                color: '#e2829a'
            },
            'Alex': {
                color: '#6386a0'
            },
            'Something Terrifying': {
                color: '#934a4f'
            },
            'Something Kind': {
                color: '#934a4f'
            }
        });

    dialogFramework
        .setGlitchConfig({
            scrambledColor:  '#000000',
            realColor: '#ffffff',
            changeSpeed: 50,
            realProbability: 5,
            autoStart: true,
            charsAllowed : 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        });

    dialogFramework
        .addScene({
            image: 'cry.png',
            speaker: 'Alex',
            text: "I wouldn't have rotted from the inside out...",
            censorSpeaker: true,
            dialogFadeInTime: 500,
            dialogFadeOutTime: 500,
            imageFadeInTime: 500,
            imageFadeOutTime: 500,
            dialogDelayIn: 800,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
        .addScene({
            image: 'pat.png',
            speaker: 'Something Terrifying',
            text: 'That must have been tough.',
            censorSpeaker: false,
            dialogFadeInTime: 500,
            dialogFadeOutTime: 500,
            imageFadeInTime: 500,
            imageFadeOutTime: 500,
            dialogDelayIn: 800,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
        .addScene({
            speaker: 'Alex',
            image: 'patsad1.png',
            text: ' .............. ',
            censorSpeaker: true,
            dialogFadeInTime: 500,
            dialogFadeOutTime: 0,
            imageFadeInTime: 500,
            imageFadeOutTime: 0,
            dialogDelayIn: 300,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
        .addScene({
            speaker: 'Something Kind',
            image: 'patsad1.png',
            text: 'It will be alright now.',
            censorSpeaker: false,
            dialogFadeInTime: 0,
            dialogFadeOutTime: 500,
            imageFadeInTime:0,
            imageFadeOutTime: -500,
            dialogDelayIn: 0,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
        .addScene({
            speaker: 'Alex',
            image: 'patsad2.png',
            text: ' . . . . . . . . . . . . . . . ',
            censorSpeaker: true,
            dialogFadeInTime: 500,
            dialogFadeOutTime: 500,
            imageFadeInTime: -500,
            imageFadeOutTime: 500,
            dialogDelayIn: 800,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
        .addScene({
            speaker: '',
            image: null,
            text: 'Suddendly you understand why people join cults.',
            censorSpeaker: false,
            dialogFadeInTime: 200,
            dialogFadeOutTime: 200,
            imageFadeInTime: 200,
            imageFadeOutTime: 200,
            dialogDelayIn: 800,
            dialogDelayOut: 0,
            imageDelayIn: 0,
            imageDelayOut: 0
        })
}
