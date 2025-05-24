import React, { useEffect } from 'react';
import './RetroTerminal.css';
import quotes from './lojiquotes.json';

function stringToHTML(str: string): HTMLElement {
  const doc = document.createElement('div');
  doc.innerHTML = str;
  return doc;
}

function typeText(element: HTMLElement | null, delay: number, minSpeed: number, maxSpeed: number) {
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
        const typingSpeed = Math.floor(Math.random() * (maxSpeed - minSpeed + 1)) + minSpeed;
        setTimeout(type, typingSpeed);
      } else {
        element.classList.remove('typing');
        element.classList.add('typed');
        element.innerHTML = text;
      }
    }
    type();
  }, delay);
}

function setupTypewriterEffect() {
  const headerTexts = document.querySelectorAll('.terminal-header .typewriter-text');
  const bootSequenceTexts = document.querySelectorAll('.boot-sequence .typewriter-text');
  let delay = 1;

  headerTexts.forEach((element, index) => {
    typeText(element as HTMLElement, delay + index * 1000, 30, 50);
    delay += element.textContent!.length * 50 + 500;
  });

  bootSequenceTexts.forEach((element, index) => {
    typeText(element as HTMLElement, delay + index * 300, 15, 30);
    delay += element.textContent!.length * 30 + 300;
  });

  const entriesContainer = document.querySelector('.entries-container') as HTMLElement;
  setTimeout(() => {
    entriesContainer.classList.add('ready');

    const entries = document.querySelectorAll('.entry');
    entries.forEach((entry, index) => {
      setTimeout(() => {
        entry.classList.add('visible');
        const commandPrompt = entry.querySelector('.command-prompt .typewriter-text');
        typeText(commandPrompt as HTMLElement, 0, 20, 40);
        const entryTitle = entry.querySelector('.entry-title');
        typeText(entryTitle as HTMLElement, commandPrompt!.textContent!.length * 40 + 300, 25, 50);
        const fileInfo = entry.querySelector('.my-2');
        typeText(fileInfo as HTMLElement, commandPrompt!.textContent!.length * 40 + entryTitle!.textContent!.length * 50 + 600, 15, 30);
        const contentTexts = entry.querySelectorAll('.mt-2 .typewriter-text');
        let contentDelay = commandPrompt!.textContent!.length * 40 + entryTitle!.textContent!.length * 50 + fileInfo!.textContent!.length * 30;
        contentTexts.forEach((el) => {
          typeText(el as HTMLElement, contentDelay, 5, 15);
          contentDelay += el.textContent!.length * 15 + 200;
        });
      }, delay + index * 20);
    });

    const finalDelay = delay + entries.length * 2000 + 1000;
    setTimeout(() => {
      const readyPrompt = document.querySelector('.command-prompt-final') as HTMLElement;
      readyPrompt.classList.add('visible');
      const readyText = readyPrompt.querySelector('.typewriter-text');
      typeText(readyText as HTMLElement, 0, 100, 150);
    }, finalDelay);
  }, delay);
}

function setupGlitchEffects() {
  setInterval(() => {
    const terminal = document.querySelector('.terminal') as HTMLElement;
    if (Math.random() < 0.3) {
      terminal.style.transform = `translateX(${Math.random() * 4 - 2}px)`;
      setTimeout(() => {
        terminal.style.transform = 'translateX(0)';
      }, 50 + Math.random() * 100);
    }
  }, 5000);

  setInterval(() => {
    if (Math.random() < 0.1) {
      document.body.style.opacity = '0.8';
      setTimeout(() => {
        document.body.style.opacity = '1';
      }, 50 + Math.random() * 100);
    }
  }, 8000);

  setInterval(() => {
    if (Math.random() < 0.2) {
      document.documentElement.style.setProperty('--scanline-offset', `${Math.random() * 10 - 5}px`);
      setTimeout(() => {
        document.documentElement.style.setProperty('--scanline-offset', '0px');
      }, 200 + Math.random() * 300);
    }
  }, 6000);
}

interface Quote { key: string; text: string; }
interface Entry {
  id: number;
  command: string;
  title: string;
  info: string;
  content: string[];
}

const entries: Entry[] = (quotes as Quote[]).map((q, i) => ({
  id: i + 1,
  command: `ACCESS RECORDS/${q.key} -a -decrypt`,
  title: q.key.replace(/\./g, ' ').replace(/_/g, ' ').replace(/desc/i, ''),
  info: `FILE_ID: ${i + 1} | ENCRYPTION: NONE | ACCESS_COUNT: ${Math.floor(Math.random() * (987 - 12 + 1)) + 12}`,
  content: [q.text]
}));

const RetroTerminal: React.FC = () => {
  useEffect(() => {
    setupTypewriterEffect();
    setupGlitchEffects();
  }, []);

  return (
    <>
      <div className="scanline" />
      <div className="terminal turn-on">
        <div className="terminal-header typewriter-container">
          <div className="text-2xl typewriter-text">SYSTM://TERMINAL#4221 [CLASSIFIED]</div>
          <div className="text-sm typewriter-text">LONG MARCH RECORD DATABASE - RESTRICTED ACCESS</div>
        </div>
        <div className="boot-sequence typewriter-container">
          <div className="typewriter-text">BOOTING TERMINAL OS v3.77.16...</div>
          <div className="typewriter-text">INITIALIZING MEMORY BANKS... OK</div>
          <div className="typewriter-text">CHECKING FILE SYSTEM INTEGRITY... OK</div>
          <div className="typewriter-text">ESTABLISHING QUANTUM-LINK CONNECTION... OK</div>
          <div className="typewriter-text">AUTHENTICATION: APPROVED</div>
          <div className="typewriter-text">SECURITY LEVEL: ALPHA-CLEARANCE</div>
          <div className="typewriter-text">LOADING RESTRICTED FILES...100%</div>
          <div className="mt-4 typewriter-text">===== LOJI WORSHIP DATABASE ACCESSED =====</div>
        </div>
        <div className="grid grid-cols-1 gap-4 entries-container">
          {entries.map(entry => (
            <div className="entry" key={entry.id}>
              <div className="command-prompt typewriter-container">
                <span className="typewriter-text">{entry.command}</span>
              </div>
              <div className="entry-content">
                <div className="entry-title typewriter-text">{entry.title}</div>
                <div className="my-2 typewriter-text">{entry.info}</div>
                <div className="mt-2 typewriter-container">
                  {entry.content.map((line, idx) => (
                    <span className="typewriter-text" key={idx} dangerouslySetInnerHTML={{ __html: line }} />
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
        <div className="mt-10 command-prompt-final">
          <span className="typewriter-text">READY</span>
          <span className="cursor blink">█</span>
        </div>
      </div>
    </>
  );
};

export default RetroTerminal;
