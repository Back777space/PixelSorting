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

SortingMode sortingMode = SortingMode.BRIGHTNESS;

enum MaskingMode {
  BRIGHTNESS,
  HUE,
  SATURATION
};

MaskingMode maskingMode = MaskingMode.BRIGHTNESS;

int lowerThresh = 50;
int upperThresh = 150;

int maxSpanLength = 100;

void setup() {
  size(935,500);
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
  cp5.addRange("mask_range")
  .setBroadcast(false) 
  .setPosition(10,365)
  .setSize(400,40)
  .setHandleSize(15)
  .setRange(0,255)
  .setRangeValues(lowerThresh,upperThresh)
  .setBroadcast(true);
   
  cp5.addSlider("span_length")
  .registerProperty("maxSpanLength") 
  .setPosition(500,370)
  .setSize(175,30)
  .setRange(0,img.width)
  .setValue(100);

  initDropdowns();
}

void initDropdowns() {
  DropdownList l1 = cp5.addDropdownList("mask_mode")
    .setPosition(10, 410)
    .setBackgroundColor(color(190))
    .setItemHeight(20)
    .setBarHeight(15)
    .setColorActive(color(255, 128));

  int i = 0;
  for (SortingMode mode : SortingMode.values()) { 
    l1.addItem(mode.name(), i);
    ++i;
  }
  
  DropdownList l2 = cp5.addDropdownList("sorting_mode")
    .setPosition(500, 410)
    .setBackgroundColor(color(190))
    .setItemHeight(20)
    .setBarHeight(15)
    .setColorActive(color(255, 128));

  i = 0;
  for (SortingMode mode : SortingMode.values()) { 
    l2.addItem(mode.name(), i);
    ++i;
  }
}

void controlEvent(ControlEvent ce) {
  if(ce.isFrom("mask_range")) {
    lowerThresh = int(ce.getController().getArrayValue(0));
    upperThresh = int(ce.getController().getArrayValue(1));
  }
  else if (ce.isFrom("mask_mode")) {
    maskingMode = MaskingMode.values()[(int)ce.getValue()];
  }
  else if (ce.isFrom("sorting_mode")) {
    sortingMode = SortingMode.values()[(int)ce.getValue()];
  }
}

public void span_length(int val) {
  maxSpanLength = val;
}

void updateImage() {
  makeMask();
  mask.updatePixels();
  
  Comparator<SortingColor> c;
  switch (sortingMode) {
    case BRIGHTNESS:
      c = new BrightnessComparator();
      break;
    case HUE:
      c = new HueComparator();
      break;
    case SATURATION:
      c = new SaturationComparator();
      break;
    default:
      c = new BrightnessComparator();
  }
  sortPixels(c);
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
    switch (maskingMode) {
      case BRIGHTNESS:
        b = brightness(img.pixels[i]);
        break;
     case HUE:
        b = hue(img.pixels[i]);
        break;
      case SATURATION:
        b = saturation(img.pixels[i]);
        break;
    }
    color fill = color(0,0,0);
    if (b <= upperThresh && b >= lowerThresh) {
      fill = color(255,255,255);
    }
    mask.pixels[i] = fill;
  }
}

void sortPixels(Comparator<SortingColor> comparator) {
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
    Arrays.sort(span, comparator);
    for (int j = 0; j < span.length; j++) {
      sorted.pixels[i+j] = span[j].col;
    }
    i = end;
  }
}

// returns pixel where span ends (exclusive)
int findLastInRow(int start){
  int i = start;
  while (i < img.pixels.length) {
    if ((i % img.width == 0 && i != start) ||
      isBlack(mask.pixels[i]) ||
      i - start >= maxSpanLength) {
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
  Float brightness;
  Float hue;
  Float saturation;

  SortingColor(color c) {
    col = c;
    brightness = brightness(c);
    hue = hue(c);
    saturation = saturation(c);
  }
}

class BrightnessComparator implements Comparator<SortingColor> {
  int compare(SortingColor c1, SortingColor c2) {
    return c1.brightness.compareTo(c2.brightness);
  }
}

class HueComparator implements Comparator<SortingColor> {
  int compare(SortingColor c1, SortingColor c2) {
    return c1.hue.compareTo(c2.hue);
  }
}

class SaturationComparator implements Comparator<SortingColor> {
  int compare(SortingColor c1, SortingColor c2) {
    return c1.saturation.compareTo(c2.saturation);
  }
}
