// sequence.js - Define your RPG dialog sequences here
// The setup function will be called automatically when the page loads

function setupScene() {
    dialogFramework
        .addScene({
            delay: 500,
            image: 'youre_andrew.png',
            speaker: '',
            text: 'You are Andrew!',
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: '',
            image: 'ashley_close.png',
            text: '',
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: '',
            image: 'ashley_open.png',
            text: '',
            fade: true
        })
        .addScene({
            delay: 500,
            speaker: 'Andrew',
            image: 'guilty.png',
            text: 'I never knew what I was guilty of',
            fade: true
        })
        .addScene({
            delay: 0,
            speaker: 'Andrew',
            image: 'guilty.png',
            text: 'But I keep coming when you call (coming when you call)',
            fade: false
        });
}

/*
 SCENE OPTIONS REFERENCE:

 delay: number (milliseconds)
 - Time to wait after image displays before showing text
 - Use 0 for immediate text, 1000+ for dramatic pauses

 image: string (file path or URL)
 - Background image to display
 - Can be local file or web URL
 - Optional - leave out to keep current background

 speaker: string ('Ashley', 'Andrew', or '')
 - 'Ashley' = pink colored name with quotes around text
 - 'Andrew' = green colored name with quotes around text
 - '' (empty) = narrator mode, no name shown, no quotes

 text: string
 - The dialog text to display
 - Automatically wraps to fit 2 lines (~50 chars per line)
 - Leave empty '' to show no dialog box

 fade: boolean (true/false)
 - true = smooth fade transitions between dialogs
 - false = instant text replacement (good for rapid exchanges)
 - Default is true if not specified
*/
