import processing.video.*;
//import javax.bluetooth.*;


FilmSwitcher myMovie;
double start_time;

BitReader bit;

int w, h;

// bitalino


void setup() {
  background(0);

  //this.setupBitalino();


  fullScreen(2);
  w = width;
  h = height;
  System.out.println(w);
  System.out.println(h);
 

  myMovie = new FilmSwitcher(this, /*dataPath("") ++*/ "DRAFT_JERWOOD_04.09.18.mp4", bit);
  //frameRate(24);
  myMovie.play();
  //bit.shouldStop();
}

void draw() {
  /*
  PImage img;
  img = myMovie.getActive().get();
  img.resize(w,h);
  image(img,0,0);*/
  
  myMovie.read();
  image(myMovie.getActive(), 0, 0, w, h);
  //image(myMovie.getActive(), 0, 0);
}

void movieEvent(Movie m) {
  //System.out.print("Event ");
  //m.read();
  myMovie.read();
}

void setupBitalino() {

  bit = new BitReader(/*this*/);

  delay(7 * 1000); // 15 seconds

  for (int i=0; (i<4 && (! bit.isPaired())); i++) {
    try {
      bit.pair();
    } 
    catch (Exception e) {
      System.out.println("waiting...");
      delay(7 * 1000);
    }
  }
  delay(5);
  //bit.getPorts();

  try {
    bit.open();
    System.out.println("Success!");
  } 
  catch (Exception e) {
    System.out.println("Failure!");
  }
}
