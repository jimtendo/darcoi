// If the position on the y axis is between 0.6 and 0.7, offset the pixel by- 0.1
if (position.y > 0.6 && position. y < 0.7) {
    pixel = getPixelAt(position.x - 0.1, position.y);
}

// If the position on the y axis is between 0.2 and 0.4, offset the pixel by the volume (position.x + volume)
if (position.y > 0.2 && position. y < 0.4) {
    pixel = getPixelAt(position.x + volume, position.y);
}