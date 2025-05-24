document.addEventListener('DOMContentLoaded', function() {
    // Add typewriter effect to all elements
    setupTypewriterEffect();
    
    // Add random glitch effects
    setupGlitchEffects();
    
    // Navigation card click events
    const navCards = document.querySelectorAll('.nav-card');
    navCards.forEach(card => {
        card.addEventListener('click', function() {
            const sectionName = this.getAttribute('data-section');
            showSection(sectionName);
        });
    });
    
    // Initialize with all sections hidden
    const sections = document.querySelectorAll('.section');
    sections.forEach(section => {
        section.style.display = 'none';
    });
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
    let delay = 1000; // Initial delay
    
    // Type header elements
    headerTexts.forEach((element, index) => {
        typeText(element, delay + (index * 800), 30, 50);
        delay += element.textContent.length * 50 + 500;
    });
    
    // Type boot sequence elements
    bootSequenceTexts.forEach((element, index) => {
        typeText(element, delay + (index * 400), 20, 35);
        delay += element.textContent.length * 35 + 300;
    });
    
    // After boot sequence is complete, show navigation
    const navigationMenu = document.querySelector('.main-navigation');
    setTimeout(() => {
        if (navigationMenu) {
            navigationMenu.style.opacity = '0';
            navigationMenu.style.display = 'block';
            fadeIn(navigationMenu, 1000);
        }
    }, delay + 1000);
}
                        const entryMeta = entry.querySelector('.entry-meta');
                        if (entryMeta) typeText(entryMeta, 600, 15, 30);
                        
                        // Type entry content
                        const contentTexts = entry.querySelectorAll('.entry-text .typewriter-text');
                        contentTexts.forEach((element, textIndex) => {
                            typeText(element, 900 + (textIndex * 200), 5, 15);
                        });
                        
                    }, entryIndex * 100); // Stagger entries within section
                });
                
            }, delay + (sectionIndex * 500)); // Stagger sections
        });
        
        // Finally show the READY prompt
        const finalDelay = delay + (sections.length * 1000) + 2000;
        setTimeout(() => {
            const readyPrompt = document.querySelector('.command-prompt-final');
            if (readyPrompt) {
                readyPrompt.classList.add('visible');
                const readyText = readyPrompt.querySelector('.typewriter-text');
                if (readyText) typeText(readyText, 0, 100, 150);
            }
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

// Navigation functionality for section switching
function showSection(sectionName) {
    const sections = document.querySelectorAll('.section');
    const navButtons = document.querySelectorAll('.nav-btn');
    
    // Remove active state from all buttons
    navButtons.forEach(btn => btn.classList.remove('active'));
    
    // Add active state to clicked button
    const activeButton = Array.from(navButtons).find(btn => 
        btn.onclick && btn.onclick.toString().includes(`'${sectionName}'`)
    );
    if (activeButton) activeButton.classList.add('active');
    
    // Map short names to full section names
    const sectionMap = {
        'evolution': 'evolution_phases',
        'dialogue': 'dialogue',
        'stories': 'stories',
        'lore': 'lore',
        'projects': 'projects',
        'ui': 'ui_elements',
        'endings': 'endings'
    };
    
    if (sectionName === 'all') {
        // Show all sections
        sections.forEach(section => {
            section.style.display = 'block';
            section.classList.add('visible');
        });
    } else {
        // Map the section name
        const fullSectionName = sectionMap[sectionName] || sectionName;
        
        // Hide all sections first
        sections.forEach(section => {
            if (section.id === `section-${fullSectionName}`) {
                section.style.display = 'block';
                section.classList.add('visible');
            } else {
                section.style.display = 'none';
                section.classList.remove('visible');
            }
        });
    }
    
    // Add a command-line effect for section switching
    const sectionsContainer = document.querySelector('.sections-container');
    if (sectionsContainer) {
        sectionsContainer.style.opacity = '0.3';
        setTimeout(() => {
            sectionsContainer.style.opacity = '1';
        }, 200);
    }
}

// Enhanced navigation button interactions
document.addEventListener('DOMContentLoaded', function() {
    const navButtons = document.querySelectorAll('.nav-btn');
    
    navButtons.forEach(button => {
        // Add hover effects
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.05)';
            this.style.textShadow = '0 0 10px currentColor';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
            this.style.textShadow = '0 0 5px rgba(230, 82, 203, 1.8)';
        });
        
        // Add click effects
        button.addEventListener('click', function() {
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1.05)';
            }, 100);
        });
    });
    
    // Initially show all sections
    setTimeout(() => {
        showSection('all');
    }, 3000);
});

// Terminal command simulation
function simulateCommand(command, output) {
    const sectionsContainer = document.querySelector('.sections-container');
    if (!sectionsContainer) return;
    
    const commandDiv = document.createElement('div');
    commandDiv.className = 'command-prompt typewriter-container mb-2';
    commandDiv.innerHTML = `<span class="typewriter-text">${command}</span>`;
    
    const outputDiv = document.createElement('div');
    outputDiv.className = 'command-output typewriter-text ml-6 mb-4';
    outputDiv.innerHTML = output;
    
    sectionsContainer.prepend(outputDiv);
    sectionsContainer.prepend(commandDiv);
    
    // Auto-remove after some time
    setTimeout(() => {
        commandDiv.remove();
        outputDiv.remove();
    }, 5000);
}

// Add keyboard shortcuts for navigation
document.addEventListener('keydown', function(event) {
    if (event.ctrlKey || event.metaKey) {
        switch(event.key) {
            case '1':
                event.preventDefault();
                showSection('evolution');
                simulateCommand('> show evolution_phases', 'Displaying evolution phase records...');
                break;
            case '2':
                event.preventDefault();
                showSection('dialogue');
                simulateCommand('> show dialogue_systems', 'Accessing dialogue matrices...');
                break;
            case '3':
                event.preventDefault();
                showSection('stories');
                simulateCommand('> show narrative_archives', 'Loading story database...');
                break;
            case '4':
                event.preventDefault();
                showSection('lore');
                simulateCommand('> show lore_database', 'Retrieving foundational knowledge...');
                break;
            case '5':
                event.preventDefault();
                showSection('projects');
                simulateCommand('> show project_files', 'Opening development specifications...');
                break;
            case '0':
                event.preventDefault();
                showSection('all');
                simulateCommand('> show all_sections', 'Displaying complete database...');
                break;
        }
    }
});
