document.addEventListener('DOMContentLoaded', function() {
    // Add typewriter effect to all elements
    setupTypewriterEffect();
    
    // Add random glitch effects
    setupGlitchEffects();
});

/**
 * @param {string} str 
 * @returns {HTMLElement}
 */
function stringToHTML(str) {
    var doc = document.createElement("div")
    doc.innerHTML = str
    return doc
}

function setupTypewriterEffect() {
    // Start with the header and boot sequence
    const headerTexts = document.querySelectorAll('.terminal-header .typewriter-text');
    const bootSequenceTexts = document.querySelectorAll('.boot-sequence .typewriter-text');
    
    // Chain the typing animations
    let delay = 1; // Initial delay
    
    // Type header elements
    headerTexts.forEach((element, index) => {
        typeText(element, delay + (index * 1000), 30, 50);
        delay += element.textContent.length * 50 + 500;
    });
    
    // Type boot sequence elements
    bootSequenceTexts.forEach((element, index) => {
        typeText(element, delay + (index * 300), 15, 30);
        delay += element.textContent.length * 30 + 300;
    });
    
    // After boot sequence is complete, show entries one by one
    // delay += 100;
    const entriesContainer = document.querySelector('.entries-container');
    setTimeout(() => {
        entriesContainer.classList.add('ready');
        
        // Process each entry with a delay
        const entries = document.querySelectorAll('.entry');
        entries.forEach((entry, index) => {
            setTimeout(() => {
                // Make entry visible
                entry.classList.add('visible');
                
                // Type command prompt
                const commandPrompt = entry.querySelector('.command-prompt .typewriter-text');
                typeText(commandPrompt, 0, 20, 40);
                
                // Type entry title with delay
                const entryTitle = entry.querySelector('.entry-title');
                typeText(entryTitle, commandPrompt.textContent.length * 40 + 300, 25, 50);
                
                // Type file info with delay
                const fileInfo = entry.querySelector('.my-2');
                typeText(fileInfo, commandPrompt.textContent.length * 40 + entryTitle.textContent.length * 50 + 600, 15, 30);
                
                // Type content with delay
                const contentTexts = entry.querySelectorAll('.mt-2 .typewriter-text');
                let contentDelay = commandPrompt.textContent.length * 40 + 
                                  entryTitle.textContent.length * 50 + 
                                  fileInfo.textContent.length * 30;
                
                contentTexts.forEach((element) => {
                    typeText(element, contentDelay, 5, 15);
                    contentDelay += element.textContent.length * 15 + 200;
                });
                
            }, delay + (index * 20)); // Stagger each entry
        });
        
        // Finally show the READY prompt
        const finalDelay = delay + (entries.length * 2000) + 1000;
        setTimeout(() => {
            const readyPrompt = document.querySelector('.command-prompt-final');
            readyPrompt.classList.add('visible');
            
            const readyText = readyPrompt.querySelector('.typewriter-text');
            typeText(readyText, 0, 100, 150);
        }, finalDelay);
        
    }, delay);
}
/**
 * 
 * @param {HTMLElement} element 
 * @param {number} delay 
 * @param {number} minSpeed 
 * @param {number} maxSpeed 
 * @returns {void}
 */
function typeText(element, delay, minSpeed, maxSpeed) {
    if (!element) return;
    
    setTimeout(() => {
        const text = element.innerHTML;
        element.textContent = '';
        element.classList.add('typing');
        element.style.visibility = 'visible';
        
        let i = 0;
        function type() {
            if (i < text.length) {
                element.innerHTML += text.charAt(i);
                i++;
                
                // Random typing speed for more realistic effect
                const typingSpeed = Math.floor(Math.random() * (maxSpeed - minSpeed + 1)) + minSpeed;
                setTimeout(type, typingSpeed);
            } else {
                element.classList.remove('typing');
                element.classList.add('typed');
                element.innerHTML = text
            }
        }
        
        type();
    }, delay);
}

function setupGlitchEffects() {
    // Random terminal glitches
    setInterval(() => {
        const terminal = document.querySelector('.terminal');
        if (Math.random() < 0.3) { // 30% chance of glitch
            // Apply random transformation
            terminal.style.transform = `translateX(${Math.random() * 4 - 2}px)`;
            
            // Reset after a short time
            setTimeout(() => {
                terminal.style.transform = 'translateX(0)';
            }, 50 + Math.random() * 100);
        }
    }, 5000);
    
    // Occasional screen flicker
    setInterval(() => {
        if (Math.random() < 0.1) { // 10% chance of screen flicker
            document.body.style.opacity = '0.8';
            setTimeout(() => {
                document.body.style.opacity = '1';
            }, 50 + Math.random() * 100);
        }
    }, 8000);
    
    // Random interlace line shifts
    setInterval(() => {
        if (Math.random() < 0.2) { // 20% chance
            document.documentElement.style.setProperty('--scanline-offset', `${Math.random() * 10 - 5}px`);
            setTimeout(() => {
                document.documentElement.style.setProperty('--scanline-offset', '0px');
            }, 200 + Math.random() * 300);
        }
    }, 6000);
}
