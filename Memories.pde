import com.hamoid.*;

// constant
int DIVISOR            = 3;
float brightness_SPEED = 1;
float HSB_SPEED        = 3;
int FPS                = 30;
int HSB_RADIUS         = 360;
int MAX_COLOR          = 255;
boolean RECORD_VIDEO   = false;
float endFrame         = FPS * 364;

// final constant
final int MAX_RECURSION_LEVEL = 8;

// dynamic
int cellWidth  = 0;
int cellHeight = 0;
int progress   = -1;
int gridSizeX  = 1;
int gridSizeY  = 1;
float brightness[][];
float hsb[][];
float speed[][];
VideoExport videoExport;

void setup()
{
  size(1920, 1080);
  colorMode(HSB, HSB_RADIUS, MAX_COLOR, MAX_COLOR);
  fill(0);
  noStroke();
  frameRate(FPS);
  noSmooth();
  initVideoRecording();
  initGrid();
}

void draw()
{
  drawGrid();
  updateGrid();
  checkColorOverflow();
  handleVideoRecording();
}

void initVideoRecording()
{
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(FPS);
  if (RECORD_VIDEO) {
    videoExport.startMovie();
  }
}

void handleVideoRecording()
{
  if (!RECORD_VIDEO) {
    return;
  }
  
  videoExport.saveFrame();
  printVideoProgress();
  exitWhenFrameCountReached();
}

void exitWhenFrameCountReached()
{
  if (frameCount > endFrame) {
    videoExport.endMovie();
    exit();
  }
}

void printVideoProgress()
{
  int done = (int)((frameCount / endFrame) * 100.0);
  if (done > progress) {
    progress = done;
    println(progress + "%");
  }
}

void resetCell(int x, int y)
{
  brightness[y][x] = -1;
  hsb[y][x] += HSB_SPEED;
  if (hsb[y][x] >= HSB_RADIUS) {
    hsb[y][x] %= HSB_RADIUS;
  }
}

void increaseNeighbourBrightness(int x, int y, int level)
{
  if(level > MAX_RECURSION_LEVEL) {
    return;
  }
  
  resetCell(x, y);
  for (int a = -1; a <= 1; ++a) {
    for (int b = -1; b <= 1; ++b) {
      int ya = y + a;
      int xb = x + b;
      if (ya < 0 || ya >= gridSizeY || xb < 0 || xb >= gridSizeX || brightness[ya][xb] < 0) {
        continue;
      }
      brightness[ya][xb] += speed[ya][xb];
      if(brightness[ya][xb] >= MAX_COLOR) {
        increaseNeighbourBrightness(xb, ya, ++level);
      }
    }
  }
}

void checkColorOverflow()
{
  for (int y = 0; y < gridSizeY; ++y) {
    for (int x = 0; x < gridSizeX; ++x) {
      if (brightness[y][x] >= MAX_COLOR) {
        increaseNeighbourBrightness(x, y, 0);
      }
    }
  }
}

void updateGrid()
{
  for (int y = 0; y < gridSizeY; ++y) {
    for (int x = 0; x < gridSizeX; ++x) {
      brightness[y][x] += speed[y][x];
    }
  }
}

void initGrid()
{
  gridSizeX  = width / DIVISOR;
  gridSizeY  = height / DIVISOR;
  cellWidth  = width / gridSizeX;
  cellHeight = height / gridSizeY;
  brightness = new float[gridSizeY][gridSizeX];
  hsb        = new float[gridSizeY][gridSizeX];
  speed      = new float[gridSizeY][gridSizeX];

  int i = 0;
  for (int y = 0; y < gridSizeY; ++y) {
    for (int x = 0; x < gridSizeX; ++x) {
      ++i;
      brightness[y][x] = (sin(i+x) * cos(i-y)) * MAX_COLOR;
      hsb[y][x]        = i * width + i % HSB_RADIUS;
      speed[y][x]      = brightness_SPEED;
    }
  }
}

void drawGrid()
{
  for (int y = 0; y < gridSizeY; ++y) {
    for (int x = 0; x < gridSizeX; ++x) {
      fill(hsb[y][x], MAX_COLOR, brightness[y][x]);
      rect(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
    }
  }
}
