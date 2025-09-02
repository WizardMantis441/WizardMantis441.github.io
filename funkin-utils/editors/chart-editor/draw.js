export function drawGrid(ctx, xPos, yPos, gridSize, gridsHoriz, gridsVert) {
    let everyOther = false;
    ctx.strokeStyle = "black";

    ctx.lineWidth = 1;
    for (let j = 0; j < gridsVert; j++) {
        for (let i = 0; i < gridsHoriz; i++) {
            everyOther = !everyOther;
            ctx.fillStyle = everyOther ? "rgb(0, 0, 0, 0.25)" : "rgb(0, 0, 0, 0.125)";
            ctx.fillRect(xPos + i * gridSize, yPos + j * gridSize, gridSize, gridSize);
            ctx.strokeRect(xPos + i * gridSize, yPos + j * gridSize, gridSize, gridSize);
        }
    }

    ctx.lineWidth = 2.75;
    for (let i = 1; i <= gridsHoriz; i += 4) {
        ctx.beginPath();
        ctx.moveTo(xPos + i * gridSize, 0);
        ctx.lineTo(xPos + i * gridSize, ctx.canvas.height);
        ctx.stroke();
    }
}

export function drawNotes(ctx, notes, getColForId, conductor, xPos, yPos, gridSize, noteSprite, noteFrameW, noteFrameH) {
    if (notes && Array.isArray(notes)) {
        notes.forEach(note => {
            const col = getColForId(note.id);
            if (col === null) return;
            const noteX = xPos + col * gridSize;
            const noteY = yPos + conductor.getYForNote(note, gridSize);
            const sx = (note.id % 4) * noteFrameW;
            const sy = 0;
            ctx.drawImage(
                noteSprite,
                sx, sy, noteFrameW, noteFrameH,
                noteX, noteY,
                gridSize, gridSize
            );
        });
    }
}

// this is kinda misleading but it's actually the highlight around the notes not the note itself
export function drawSelectedNotes(ctx, selectedNotes, getColForId, conductor, xPos, yPos, gridSize) {
    selectedNotes.forEach(note => {
        const colIndex = getColForId(note.id);
        if (colIndex === null) return;
        const noteX = xPos + colIndex * gridSize;
        const noteY = yPos + conductor.getYForNote(note, gridSize);
        ctx.strokeStyle = 'yellow';
        ctx.lineWidth = 2.5;
        ctx.strokeRect(noteX, noteY, gridSize, gridSize);
    });
}

export function drawHoveredNote(ctx, hoveredGrid, noteSprite, noteFrameW, noteFrameH, xPos, yPos, gridSize) {
    if (hoveredGrid && hoveredGrid.col >= 1 && hoveredGrid.col <= 8) {
        const noteX = xPos + hoveredGrid.col * gridSize;
        const noteY = yPos + hoveredGrid.snapStep * gridSize;
        ctx.globalAlpha = 0.25;
        ctx.drawImage(noteSprite, noteFrameW * ((hoveredGrid.col - 1) % 4), 0, noteFrameW, noteFrameH, noteX, noteY, gridSize, gridSize);
        ctx.globalAlpha = 1.0;
    }
}

export function drawSongPosBar(ctx, conductor, xPos, yPos, gridSize, gridsHoriz) {
    ctx.beginPath();
    ctx.moveTo(xPos - 10, yPos + conductor.curStep * gridSize);
    ctx.lineWidth = 2;
    ctx.strokeStyle = "red";
    ctx.lineTo(xPos + gridsHoriz * gridSize + 10, yPos + conductor.curStep * gridSize);
    ctx.stroke();
}