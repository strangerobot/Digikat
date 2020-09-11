import controlP5.*;

//variables for the interface
ControlP5 cp5;
Slider2D gridControl;
ButtonBar b;

float gradient_start;
float gradient_strength;
int RESIST_THREAD_COUNT;
int MARGIN;
int HOURLY_WAGE;
int gradient_end;
int NUM_COLORS;
int design;

//Dithered image
QImage ikatDesign;

//set number of artworks loaded here
int numDesigns = 9;
PImage[] myArt = new PImage[numDesigns];


//layout variables
int sariMargin=120;
int marginSet = 60;
PFont titles;


//Cost generation variables
int complexityScore;
int materialCost;
int labor;
String difficulty;
String materialz;


//saved colors
color c;
color weave;
color UIfont = #343767;
color sariCol;
String tempColor; 
IntList swatches;
int[] finalSwatches; 
float counter;




void setup() {
  size(1400, 800); 
  cp5 = new ControlP5(this);
  swatches = new IntList();
  titles = loadFont("AdobeDevanagari-Bold-48.vlw");


  ///////INTERFACE

  cp5.addSlider("design")
    .setRange(0, numDesigns-1)
    .setValue(5)
    .setHeight(20)
    .setWidth(200)
    .setPosition(marginSet, height-100)
    .setNumberOfTickMarks(numDesigns)
    .setColorCaptionLabel(UIfont)
    ;

  cp5.addButtonBar("material")
    .setPosition(marginSet, height-130)
    .setSize(200, 20)
    .addItems(split("SILK COTTON", " "))
    ;


  cp5.addSlider("HOURLY_WAGE")
    .setRange(20, 500)
    .setColorValue(UIfont)
    .setValue(200)
    .setPosition(780, height-130)
    .setColorCaptionLabel(UIfont)
    .setSize(30, 100);

  cp5.addSlider("MARGIN")
    .setRange(10, 50)
    .setColorValue(UIfont)
    .setValue(40)
    .setNumberOfTickMarks(5)
    .setPosition(850, height-130)
    .setColorCaptionLabel(UIfont)
    .setSize(30, 100);


  cp5.addSlider("NUM_COLORS")
    .setRange(1, 20)
    .setValue(6)
    .setColorValue(UIfont)
    .setPosition(450, height-130)
    .setColorCaptionLabel(UIfont)
    .setSize(30, 100);


  cp5.addSlider("RESIST_THREAD_COUNT")
    .setRange(2, 15)
    .setValue(2)
    .setPosition(530, height-130)
    .setColorCaptionLabel(UIfont)
    .setSize(120, 20);

  cp5.addSlider("gradient_start")
    .setRange(0, 1000)
    .setValue(0)
    .setPosition(530, height-105)
    .setColorCaptionLabel(UIfont)
    .setSize(120, 20);

  cp5.addSlider("gradient_end")
    .setRange(0, 200)
    .setValue(0)
    .setPosition(530, height-80)
    .setColorCaptionLabel(UIfont)
    .setSize(120, 20);

  cp5.addSlider("gradient_strength")
    .setRange(0, 5)
    .setValue(1)
    .setColorCaptionLabel(UIfont)
    .setPosition(530, height-55)
    .setSize(120, 20);

  cp5.addColorWheel("SARI_COLOR", 320, height-130, 100)
    .setColorCaptionLabel(UIfont)
    .setRGB(color(128, 0, 255)) 
    ;


  //LOAD THE DESIGNS
  for (int i=0; i < myArt.length; i++) {
    myArt [i] = loadImage( "art"+i+".png");
  }
}


int index(int x, int y) {
  return x + y * myArt[design].width;
}


void draw() {
  //////// LOAD DESIGNS INTO THE DITHERING CODE
  ikatDesign= new QImage(myArt[design], NUM_COLORS);

  //////// SET BASE COLOR
  sariCol=color(cp5.get(ColorWheel.class, "SARI_COLOR").getRGB());


  /////// START
  background(255);
  pushMatrix();
  translate(marginSet, 80);
  fill(sariCol);
  noStroke();
  rectMode(CORNER);

  ////SAREE BASE COLOR
  rect(0, 0, ikatDesign.getImage().width, ikatDesign.getImage().height); //BASE SARI COLOR

  ////DRAW THE PIXEL COLORS FROM THE DITHERED IMAGE (PART 1)
  float tempgradient_start= map(gradient_start, 0, 500, 0, 1);
  for (int x=ikatDesign.getImage().width-1-gradient_end; x>gradient_start; x=x-RESIST_THREAD_COUNT) {
    counter=counter+tempgradient_start;
    for (int y=0; y<ikatDesign.getImage().height-RESIST_THREAD_COUNT; y=y+RESIST_THREAD_COUNT) {

      //TALLY THE CHANGE OF COLOR FROM PIXEL TO PIXEL TO ESTIMATE THE TIME REQUIRED TO MAKE THE SAREE
      complexity(x, y);

      noStroke();
      stroke(weave);
      fill(weave);
      if (gradient_start<1) {
        rect(x-RESIST_THREAD_COUNT, y, RESIST_THREAD_COUNT, RESIST_THREAD_COUNT);
      } else {
        rect(x-RESIST_THREAD_COUNT, y, (RESIST_THREAD_COUNT/(0.1*(RESIST_THREAD_COUNT+(gradient_strength*counter)))), RESIST_THREAD_COUNT);
      }
    }
  }

  ////DRAW THE PIXEL COLORS FROM THE DITHERED IMAGE (PART 2 - TO THE RIGHT OF THE GRADIENT)

  for (int x=(ikatDesign.getImage().width-1-gradient_end); (x<ikatDesign.getImage().width-1); x=x+RESIST_THREAD_COUNT) {
    counter=counter+tempgradient_start;
    for (int y=0; y<ikatDesign.getImage().height; y=y+RESIST_THREAD_COUNT) {
      weave = ikatDesign.getImage().get(x, y);
      //noStroke();
      stroke(weave);
      fill(weave);
      rect(x-RESIST_THREAD_COUNT, y, RESIST_THREAD_COUNT, RESIST_THREAD_COUNT);
    }
  }

  //////DRAW LINES FROM UNDERLAYING COLOR TO GIVE WOVEN IMPRESSION
  for (int x=0; x<ikatDesign.getImage().width; x=x+5) {
    for (int y=0; y<ikatDesign.getImage().height-30; y=y+30) {
      stroke(sariCol);
      strokeWeight(0.5);
      line(x, y, x, y+25);
    }
  }
  //}

  ///LOAD & DISPLAY THE LIST OF FINAL COLORS USED IN THE DESIGN
  for (int loop=0; loop<ikatDesign.getColorTable().length; loop++) {
    swatches.append(ikatDesign.getColorTable()[loop]);
  }
  swatches.append(sariCol);
  noStroke();

  for (int i=0; i<swatches.size(); i++) {
    swatches.sort();
    color palette = swatches.get((i));
    fill(palette);
    rect(width-150, (i*25), 20, 20);
    fill(255, 255, 255, 100);
  }

  popMatrix();
  titleType();
  swatches.clear();
  
  ////RESET VALUES
  counter=0;
  complexityScore=0;
}


/////DIFFICULTY CALCULATOR
void complexity(int tX, int tY) {
  weave = ikatDesign.getImage().get(tX, tY);
  color weave2 = ikatDesign.getImage().get(tX, tY+1);

  float oldR = red(weave);
  float oldG = green(weave);
  float oldB = blue(weave);

  float nextR = red(weave2);
  float nextG = green(weave2);
  float nextB = blue(weave2);

  float diffR= oldR-nextR;
  float diffG= oldG-nextG;
  float diffB= oldB-nextB;

  //println(nextR);
  if (diffR != 0 || diffG  != 0  || diffB  != 0 ) {
    complexityScore++;
  }
}


/////COST CALCULATION
void calculation() {
  difficulty();
  labor = int(map(complexityScore, 300, 10000, 4, 14));
  int cost = materialCost+int(labor*HOURLY_WAGE*8)+(ikatDesign.getColorTable().length*100);
  textFont(titles, 8);
  fill(255);
  text("This " + difficulty +" "+ materialz + " saree, with its "+ (ikatDesign.getColorTable().length) 
    + " colors, will require close to " + labor +" days to tie, dye, and weave. When remunerating the artisans making it " + HOURLY_WAGE 
    + " INR per hour of work, you will have a total production cost of " + cost + " INR.", 940, height-160, 300, 200);
  text("For a total retail price of " + int(cost*(1+MARGIN*0.01)) + " INR with a " + MARGIN + "% margin.", 940, height-50, 300, 100);
}

/////SET SILK / COTTON
void material(int n) {
  if (n==1) {
    materialCost=1500+labor*20;
    materialz= "cotton";
  }
  if (n==0) {
    materialCost=2500+labor*150;
    materialz= "silk";
  }
}


/////DIFFICULTY SWITCH
void difficulty() {
  if (complexityScore<800) {
    difficulty= "simple";
  }
  if ((complexityScore>=800 && complexityScore<=4000)) {
    difficulty= "intricate";
  }
  if (complexityScore>4000) {
    difficulty= "very complex";
  }
}


////DISPLAY TYPE OF UI
void titleType() {
  int textH=height-150;
  fill(UIfont);
  rect(marginSet-15, 0, 250, 50);
  textFont(titles, 12);
  fill(255);
  text("COST CALCULATOR", marginSet, 35);

  fill(UIfont);
  textFont(titles, 10);
  text("1 | Choose design & material", marginSet, textH);
  text("2 | Adjust colors", 320, textH);
  text("3 | Adjust complexity", 530, textH);
  text("4 | Fine-tune cost", 760, textH);

  rect(920, textH-30, 370, 200);
  stroke(UIfont);
  noFill();
  rect(0, 0, width, height);
  calculation();
}
