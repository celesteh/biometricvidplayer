import processing.video.*;
//import javax.bluetooth.*;
import java.util.Random;


FilmSwitcher myMovie;
double start_time;
double last_change;
float jumpProbability;
//BreakPoint[] breakpoints;
BiometricController controller;
BreakPoint last, next;

BitReader bit;

int w, h;

float alpha;
boolean alive;
double fadeTime;
double jumpPause;
int fadeDelta = 3;
boolean runFullScreen;

Random rand;

// bitalino


void setup() {
  background(0);
  last_change = 0;

  //breakpoints = new BreakPoint[0];

  controller = new BiometricController(this, dataPath("")+"/biometric.properties");
  jumpProbability = 0;
  /*
  last = controller.getFirstBreakPoint();
   if (last != null) {
   if (last.getTime() > 0) {
   next = last;
   last = new BreakPoint(0, 0);
   } else {
   jumpProbability = last.getValue();
   try {
   next = controller.getNextBreakPoint(0);
   
   System.out.println("last " + last.getTime() + ":" + last.getValue() + " next " + next.getTime() + ":" + next.getValue());
   } 
   catch (Exception e) {
   }
   }
   
   } else {
   // set up a dummy one anyway to simplify test conditions later
   last = new BreakPoint(0, 0);
   }
   */
  rand = new Random();



  fullScreen(2);
  w = width;
  h = height;
  System.out.println(w);
  System.out.println(h);

  alpha = 0;
  alive = false;
  try {
    fadeTime = Double.parseDouble(controller.getSetting("fadeTime"));
  } 
  catch (Exception e) {
    fadeTime = 5;
    controller.setSetting("fadeTime", ""+fadeTime);
  }
  try {
    jumpPause = Double.parseDouble(controller.getSetting("jumpPause"));
  } 
  catch (Exception e) {
    jumpPause = 4000;
    controller.setSetting("jumpPause", ""+jumpPause);
  }
  try {
    runFullScreen = Boolean.parseBoolean(controller.getSetting("runFullScreen"));
  } 
  catch (Exception e) {
    runFullScreen = true;
    controller.setSetting("runFullScreen", ""+runFullScreen);
  }
  String film;
  try {
    film = controller.getSetting("film");
  } 
  catch (Exception e) {
    film = "DRAFT_JERWOOD_04.09.18.mp4";
  }

  System.out.println(film);

  myMovie = new FilmSwitcher(this, film/*, bit*/);
  myMovie.loadClips(dataPath("")+"/clips");

  frameRate(24); // was 24
  //myMovie.play();
  //bit.shouldStop();


  // just for testing
  //fadeIn();

  this.setupBitalino();
  start_time = System.currentTimeMillis(); // duplicated later because
}

void draw() {
  //imageMode(CENTER);
  //System.out.println("draw()");
  /*
  PImage img;
   img = myMovie.getActive().get();
   img.resize(w,h);
   image(img,0,0);*/

  update();

  //tint(255, alpha); rgb
  tint(alpha);

  try {
    if (alpha > 0) {
      if (myMovie.isPlaying()) {
        myMovie.read();
        if (runFullScreen) {
          image(myMovie.getImage(), 0, 0, w, h);
          //System.out.println("fullscreen");
        } else {
          image(myMovie.getImage(), 0, 0);
          //System.out.println("not fullscreen");
        }
        //image(myMovie.getImage(), 0, 0, w, h);
      }
    }
  } 
  catch (Exception e) {
    System.out.println(e);
    e.printStackTrace();
  }
}

void update() {

  // do fade
  doFade();
  try {
    if (alpha >= 1) {
      if (shouldChange()) {
        myMovie.change();
      }
    }
  } catch (Exception e) {
    System.out.println("Caucght exception on change " + e);
    myMovie.resumeMain();
  }
}

/*
void movieEvent(Movie m) {
 //System.out.print("Event ");
 //m.read();
 myMovie.read();
 }
 */

boolean shouldChange() {

  boolean doIt = false;
  double time;
  float ecg, emg, probability;


  try {
    ecg = bit.getECG();
    emg = bit.getEMG();
  } 
  catch (Exception e) {
    System.out.println("bit failed");
    ecg = emg = 1;
  }

  if (alive) {
    /*
    if (next != null) {
     if (! next.isFuture())
     last = next;
     try {
     next = controller.getNextBreakPoint(last.currentTime());
     next.setStart(start_time);
     } 
     catch (Exception e) {
     }
     }
     if (next != null) {
     jumpProbability = last.currentValue(next);
     }
     */
    time = getElapsedTime();
    //System.out.println("time " + time + " start_time " + start_time);
    jumpProbability = controller.getProbabilityAt(time);

    if ( (time - last_change) > controller.getPauseAt(time)) {
      probability = ecg * emg * jumpProbability;
      //System.out.println("probability " + probability+ " " + ecg + " " + emg + " time " + time);
      if (rand.nextFloat() <= (probability/48)) { // 2 second window size
        System.out.println("Switch!");
        last_change = time;//getElapsedTime();
        doIt = true;
      }
    }
  }

  return doIt;

  //return rand.nextBoolean();
}

void doFade() {
  if (alive && alpha < 255) {
    //alpha += fadeDelta;
    lerp(1, 2, 3);
    alpha = lerp(0, 256, (float) (getElapsedTime() / (fadeTime * 1000)));
    //System.out.println("alpha "+ alpha);
    if (alpha > 255) alpha = 255;
  } else if (!alive && alpha > 0) {
    alpha -= fadeDelta;
    //alpha = lerp(255.0, 0.0, ((float) getElapsedTime() / fadeTime));
    if (alpha < 0) alpha = 0;
  }
}

void fadeIn() {

  start_time = System.currentTimeMillis();
  System.out.println("star_time " + start_time);
  /*
  last.setStart(start_time);
   if (next != null) { 
   next.setStart(start_time);
   }
   */
  myMovie.play();
  alive = true;
}

void fadeOut() {
  alive = false;
  try {
    bit.shouldStop();
  } 
  catch (Exception e) {
    System.out.println("fade out " + e);
  }
}

void keyPressed() {

  if (alive) {
    fadeOut();
  } else {
    fadeIn();
  }
}

public double getElapsedTime() {

  return System.currentTimeMillis() - start_time;
}

public void setJumpProbability(float probability) {
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
    controller.ready();
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
    System.out.println("bp " + parse + " " + parts[0] /*+ " - " + parts[1]*/);
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


  public boolean isFuture() {
    return isFuture(currentTime());
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

    float current, numerator, ratio, result=value;
    current = ((float)currentTime() );
    /*
    numerator = ((float)(current - time));
     if ( numerator <= 0) {
     //ratio = 0;
     result = getValue();
     } else {
     if (current >= secondPoint.getTime()) {
     //ratio =1;
     result = secondPoint.getValue();
     } else {
     ratio = (float) (numerator / timeDistance(secondPoint)); 
     result = lerp(value, secondPoint.getValue(), ratio);
     }
     */
    return valueAt(secondPoint, current);
  }

  public float valueAt(BreakPoint secondPoint, double when) {

    float current, numerator, ratio, result=value;
    //current = time;//((float)currentTime() );
    //numerator = ((float)(current - time));
    ratio = -1;
    numerator = (float) (when - time);
    if ( when <= time) {
      //ratio = 0;
      result = getValue();
    } else {
      if (when >= secondPoint.getTime()) {
        //ratio =1;
        result = secondPoint.getValue();
      } else {
        ratio = (float) (numerator / timeDistance(secondPoint)); 
        result = lerp(value, secondPoint.getValue(), ratio);
      }
    }
    //System.out.println("when " + when + " time " + time + " second " + secondPoint.getTime());
    //System.out.println("ratio " + ratio + " result " + result);

    return result;
  }


  public String toString() {
    return (""+time+":"+value);
  }
}
