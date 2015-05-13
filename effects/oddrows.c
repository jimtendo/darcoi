// Create variable to hold whether the row is odd or not (10 is the number of rows you want to divide it into)
bool oddRow  = bool(mod(int(position.y * 40.0), 2));

// If the row is odd, offset the pixel to the right by volume divided by 10
if (oddRow) {
    pixel = getPixelAt(position.x + volume/10.0, position.y);
}

// If the row is odd, offset the pixel to the left by volume divided by 10
else {
   pixel = getPixelAt(position.x - volume/10.0, position.y);
} 
