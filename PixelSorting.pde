import java.util.*;

PImage img;
PImage sorted;
PImage mask;

import controlP5.*;

ControlP5 cp5;

enum SortingMode {
  BRIGHTNESS,
  HUE,
  SATURATION
};

SortingMode mode = SortingMode.BRIGHTNESS;

int lowerThresh = 50;
int upperThresh = 150;

int maxSpanLength = 100;

void setup() {
  size(925,450);
  cp5 = new ControlP5(this);
 
  initImages(); 
  initGUI();
}

void initImages() {
  img = loadImage("gwtpe.jpg");
  
  mask = img.get();
  mask.loadPixels();
  
  sorted = img.get();
  sorted.loadPixels();
  sorted.updatePixels();

  updateImage();
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

  initDropdown();
}

void initDropdown() {
  DropdownList list = cp5.addDropdownList("Sorting mode")
    .setPosition(750, 365)
    .setBackgroundColor(color(190))
    .setItemHeight(20)
    .setBarHeight(15)
    .setColorActive(color(255, 128));

  int i = 0;
  for (SortingMode mode : SortingMode.values()) { 
    list.addItem(mode.name(), i);
    ++i;
  }
}

void controlEvent(ControlEvent ce) {
  if(ce.isFrom("maskRange")) {
    lowerThresh = int(ce.getController().getArrayValue(0));
    upperThresh = int(ce.getController().getArrayValue(1));
  }
}

public void spanLength(int val) {
  maxSpanLength = val;
}

void updateImage() {
  // makeMask();
  makeHueMask();
  mask.updatePixels();
  sortPixels();
  sorted.updatePixels();
}

void draw() {
  background(0);
  image(img, 0, 0);
  image(mask, 310, 0);
  image(sorted, 620, 0);
  updateImage();
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

void makeHueMask() {
    for (int i = 0; i < img.pixels.length; i++) {
    float h = hue(img.pixels[i]);
    color fill = color(0,0,0);
    if (h <= upperThresh && h >= lowerThresh) {
      fill = color(255,255,255);
    }
    mask.pixels[i] = fill;
  }
}

void sortPixels() {
  for (int i = 0; i < img.pixels.length; i++) {
    int end = findLastInRow(i);
    if (end == i) {
      sorted.pixels[i] = img.pixels[i];
      continue;
    }
    SortingColor[] span = new SortingColor[end - i];
    for (int j = 0; j < span.length; j++) {
      span[j] = new SortingColor(img.pixels[i + j]);
    }
    Arrays.sort(span, new BrightnessComparator());
    for (int j = 0; j < span.length; j++) {
      sorted.pixels[i+j] = span[j].col;
    }
    i = end;
  }
}

int findLastInRow(int start){
  int i = start;
  while (i < img.pixels.length) {
    if ((i % img.width == 0 && i != start) ||
      isBlack(mask.pixels[i]) ||
      i - start == maxSpanLength) {
        break;
    }
    ++i;
  }
  return i;
}

boolean isBlack(color pix) {
  return brightness(pix) == 0.0f;
}

class SortingColor {
  color col;
  float brightness;
  float hue;

  SortingColor(color c) {
    col = c;
    brightness = brightness(c);
    hue = hue(c);
  }
}

class BrightnessComparator implements Comparator<SortingColor> {
  int compare(SortingColor c1, SortingColor c2) {
    return int(c1.brightness - c2.brightness);
  }
}

class HueComparator implements Comparator<SortingColor> {
  int compare(SortingColor c1, SortingColor c2) {
    return int(c1.hue - c2.hue);
  }
}
