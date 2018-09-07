import processing.video.*;

Movie myMovie;
//Rectangle monitor;
double start_time;

void setup() {
  size(200, 200);
  

  myMovie = new Movie(this, /*dataPath("") ++*/ "DRAFT_JERWOOD_04.09.18.mp4");
  myMovie.play();
}

void draw() {
  image(myMovie, 0, 0);
}

void movieEvent(Movie m) {
  m.read();
}
/*
  public java.awt.Dimension getPreferredSize() {
    
    return new java.awt.Dimension(monitor.width, monitor. height);
  }
 */
