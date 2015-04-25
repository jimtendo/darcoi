if (pixel.r > 0.1 && pixel.g > 0.1 && pixel.b > 0.1) {
    pixel.r = 0.0;
    pixel.g = 0.0;
    pixel.b = (pixel.r + pixel.g + pixel.b) / 3.0;
}

else {
    pixel.r = 0.0;
    pixel.g = 0.0;
    pixel.b = 0.0;
}