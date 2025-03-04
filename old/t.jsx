const colorMap = {
    "C": "rgb(35,206,255)", // cyan
    "L": "rgb(195,176,145)", // dirty orange-gray (lilac)
    "W": "rgb(255,255,255)", // white
    "B": "rgb(0,0,255)", // blue
    "G": "rgb(0,159,3)", // green
    "R": "rgb(255,50,50)", // red
    "b": "rgb(0,0,0)", // black
    "g": "rgb(176,176,176)", // light gray
    "Y": "rgb(255,189,0)", // yellow
    "H": "rgb(255,189,0)", // yellow (same as Y)
    "T": "rgb(255,255,255)", // white (same as W)
    "O": "rgb(255,112,25)", // orange
    "0": "rgb(203,0,203)", // purple
    "1": "rgb(128,120,211)", // lilac
    "2": "rgb(81,112,243)", // blue
    "3": "rgb(81,143,220)", // gray-blue
    "4": "rgb(90,190,231)", // light blue
    "5": "rgb(63,181,194)", // dull cyan
    "6": "rgb(119,204,186)", // turquoise
    "7": "rgb(153,209,153)", // light green
    "8": "rgb(204,163,51)", // orange-yellow
    "9": "rgb(252,169,125)", // white-orange
    "t": "rgb(255,76,77)", // vivid red
};

// Convert the input text to HTML
const convertToHtml = (text) => {
    let result = [];
    let currentIndex = 0;
    let segments = [];
    let plainText = "";

    for (let i = 0; i < text.length; i++) {
        if (text[i] === "§" && i < text.length - 1) {
            const code = text[i + 1];

            // Add any plain text accumulated so far
            if (plainText.length > 0) {
                segments.push({ type: "plain", content: plainText });
                plainText = "";
            }

            if (code === "!") {
                // End the current formatting - this is handled in the renderer
                i++;
            } else if (colorMap[code]) {
                // Start a new color formatting
                segments.push({ type: "color", code: code });
                i++;
            }
        } else {
            plainText += text[i];
        }
    }

    // Add any remaining plain text
    if (plainText.length > 0) {
        segments.push({ type: "plain", content: plainText });
    }

    // Now process segments into a stack-based format for rendering
    let stack = [];
    let currentColor = null;

    for (const segment of segments) {
        if (segment.type === "plain") {
            if (currentColor) {
                result.push(
                    <span key={currentIndex++} style={{ color: colorMap[currentColor] }}>
                        {segment.content}
                    </span>
                );
            } else {
                result.push(<span key={currentIndex++}>{segment.content}</span>);
            }
        } else if (segment.type === "color") {
            currentColor = segment.code;
        } else if (segment.type === "end") {
            currentColor = null;
        }
    }

    return <div className="font-mono">{result}</div>;
};