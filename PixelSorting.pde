
PImage img;
PImage sorted;
PImage mask;

import controlP5.*;

ControlP5 cp5;

enum sortingMode {
  HORIZONTAL,
  VERTICAL
};

sortingMode mode = sortingMode.HORIZONTAL;

int lowerThresh = 50;
int upperThresh = 150;

int maxSpanLength = 100;

void setup() {
  size(925,450);
  cp5 = new ControlP5(this);
 
   switch(mode) {
    case HORIZONTAL:
      break;
    case VERTICAL:
      break;
  }
  initImages(); 
  initGUI();
}

void initImages() {
  img = loadImage("gwtpe.jpg");
  
  mask = img.get();
  mask.loadPixels();
  makeMask();
  
  sorted = img.get();
  sorted.loadPixels();
  sortPixels();
  sorted.updatePixels();
}

void initGUI() {
  cp5.addRange("maskRange")
   .setBroadcast(false) 
   .setPosition(10,365)
   .setSize(400,40)
   .setHandleSize(15)
   .setRange(0,255)
   .setRangeValues(lowerThresh,upperThresh)
   .setBroadcast(true);
   
  cp5.addSlider("spanLength")
  .registerProperty("maxSpanLength") 
   .setPosition(500,370)
   .setSize(175,30)
   .setRange(0,img.width)
   .setValue(100);
}

void controlEvent(ControlEvent ce) {
  if(ce.isFrom("maskRange")) {
    lowerThresh = int(ce.getController().getArrayValue(0));
    upperThresh = int(ce.getController().getArrayValue(1));
    updateImage();
  }
}

public void spanLength(int val) {
  maxSpanLength = val;
  updateImage();
}

void updateImage() {
  makeMask();
  mask.updatePixels();
  sortPixels();
  sorted.updatePixels();
}

void draw() {
  background(0);
  image(img, 0, 0);
  image(mask, 310, 0);
  image(sorted, 620, 0);
}

void makeMask() {
  for (int i = 0; i < img.pixels.length; i++) {
    float b = brightness(img.pixels[i]);
    color fill = color(0,0,0);
    if (b <= upperThresh && b >= lowerThresh) {
      fill = color(255,255,255);
    }
    mask.pixels[i] = fill;
  }
}

void sortPixels() {
  for (int i = 0; i < img.pixels.length; i++) {
    if (brightness(mask.pixels[i]) == 0.0f) {
       sorted.pixels[i] = img.pixels[i];
       continue;
    }
    
    int end = -1;
    if (mode == sortingMode.HORIZONTAL)
      end = findLastInRow(i);
    
    if (end == i) {
      sorted.pixels[i] = img.pixels[i];
      continue;
    }
    color[] unsorted = new color[end - i];
    for (int j = 0; j < unsorted.length; j++) {
      unsorted[j] = img.pixels[i + j];
    }
    color[] sortedPixels = sort(unsorted);
    for (int j = 0; j < unsorted.length; j++) {
      sorted.pixels[i+j] = sortedPixels[j];
    }
    i = end;
  }
}

int findLastInRow(int start){
  int i = start;
  while (i < img.pixels.length) {
    if ((i % img.width == 0 && i != start) ||
      brightness(mask.pixels[i]) == 0.0f ||
      i - start == maxSpanLength) {
        break;
    }
    ++i;
  }
  return i;
}
