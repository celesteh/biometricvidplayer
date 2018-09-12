import processing.video.*;
//import javax.bluetooth.*;


FilmSwitcher myMovie;
double start_time;
double jumpProbability;
BreakPoint[] breakpoints;
BiometricController controller;

BitReader bit;

int w, h;

float alpha;
boolean alive;
double fadeTime;
int fadeDelta = 3;

// bitalino


void setup() {
  background(0);

  jumpProbability = 0;
  breakpoints = new BreakPoint[0];

  controller = new BiometricController(this, dataPath("")+"/biometric.properties");

  //this.setupBitalino();


  fullScreen(2);
  w = width;
  h = height;
  System.out.println(w);
  System.out.println(h);

  alpha = 0;
  alive = false;
  fadeTime = Double.parseDouble(controller.getSetting("fadeTime"));


  myMovie = new FilmSwitcher(this, /*dataPath("") ++*/ "DRAFT_JERWOOD_04.09.18.mp4", bit);
  myMovie.loadClips(dataPath("")+"/clips");

  frameRate(24);
  //myMovie.play();
  //bit.shouldStop();

  // just for testing
  fadeIn();
}

void draw() {
  //imageMode(CENTER);
  //System.out.println("draw()");
  /*
  PImage img;
   img = myMovie.getActive().get();
   img.resize(w,h);
   image(img,0,0);*/

  if (alive && alpha < 255) {
    //alpha += fadeDelta;
    lerp(1, 2, 3);
    alpha = lerp(0, 256, (float) (getElapsedTime() / (fadeTime * 1000)));
    System.out.println("alpha "+ alpha);
    if (alpha > 255) alpha = 255;
  } else if (!alive && alpha > 0) {
    alpha -= fadeDelta;
    //alpha = lerp(255.0, 0.0, ((float) getElapsedTime() / fadeTime));
    if (alpha < 0) alpha = 0;
  }


  tint(255, alpha);

  if (myMovie.isPlaying()) {
    myMovie.read();  
    image(myMovie.getImage(), 0, 0);
    //image(myMovie.getImage(), 0, 0, w, h);
  }
}

/*
void movieEvent(Movie m) {
 //System.out.print("Event ");
 //m.read();
 myMovie.read();
 }
 */

void fadeIn() {

  start_time = System.currentTimeMillis();
  myMovie.play();
  alive = true;
}

void fadeOut() {
  alive = false;
}

public double getElapsedTime() {

  return System.currentTimeMillis() - start_time;
}

public void setJumpProbability(double probability) {
  jumpProbability = probability;
}


public void setJumpProbabilityBreakpoint(double target, double when) {
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

public class BreakPoint implements Comparable<BreakPoint> {


  double time, start_time;
  float value;

  public BreakPoint (double when, double what) {
    this(when, (float)what);
  }
  public BreakPoint (double when, float what) {
    time = when;
    value = what;
  }

  public BreakPoint(String parse) {

    String[] parts = parse.split(":");
    time = Double.parseDouble(parts[0]);
    value = Float.parseFloat(parts[1]);
  }

  public double getTime() {
    return time;
  }

  public float getValue() {
    return value;
  }

  public void setStart(double startTime) {
    start_time = startTime;
  }

  public boolean isFuture(double now) {
    boolean answer = false;
    if (time > now) {
      answer = true;
    }
    return answer;
  }

  public double currentTime(double startTime) {
    start_time = startTime;
    return currentTime();
  }

  public double currentTime() {
    double now = System.currentTimeMillis();
    return now - start_time;
  }


  public int compareTo(BreakPoint comparePoint) {

    int result;
    double compareTime = ((BreakPoint) comparePoint).getTime(); 

    if (time > compareTime) {
      result = 1;
    } else { 
      if (time < compareTime) {
        result = -1;
      } else {
        result = 0;
      }
    }
    //ascending order
    //return ((int) this.getTime() - compareTime);

    //descending order
    //return compareQuantity - this.quantity;

    return result;
  }

  public double timeDistance(BreakPoint comparePoint) {
    return Math.abs(time - comparePoint.getTime());
  }

  public float valueDistance(BreakPoint secondPoint) {
    return secondPoint.getValue() - value;
  }

  public float currentValue(BreakPoint secondPoint) {

    float ratio;
    ratio = (float) ((currentTime() - time) / timeDistance(secondPoint));

    return lerp(value, secondPoint.getValue(), ratio);
  }


  public String toString() {
    return (""+time+":"+value);
  }
}
