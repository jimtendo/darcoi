// If Pixel's red channel, green channel and blue channel is more than 0.1...
if (pixel.r > 0.1 && pixel.g > 0.1 && pixel.b > 0.1) {
  
    // Make the red and green channel empty, but make the blue channel the average of red, green and blue
    pixel.r = 0.0;
    pixel.g = 0.0;
    pixel.b = (pixel.r + pixel.g + pixel.b) / 3.0; // (Adding and then dividing by three is the average of rgb)
}

// Otherwise make the pixel black
else {
    pixel.r = 0.0;
    pixel.g = 0.0;
    pixel.b = 0.0;
}