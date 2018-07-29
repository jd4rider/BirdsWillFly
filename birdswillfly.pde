import de.bezier.data.sql.mapper.*;
import de.bezier.data.sql.*;

SQLite db;

PImage backImg = loadImage("http://i.imgur.com/cXaR0vS.png");
PImage birdImg = loadImage("http://i.imgur.com/mw0ai3K.png");
PImage wallImg = loadImage("http://i.imgur.com/4SUsUuc.png");
PImage startImg = loadImage("http://i.imgur.com/U6KEwxe.png");
int gamestate = 1;
int score = 0;
int highScore = 0;
int highScorePosY = 40;
ArrayList namedb = new ArrayList();
ArrayList scoredb = new ArrayList();
String name = "";
float x = -200, y, vy = 0.0;
boolean dbQueryFlag = true; 

int[] wx = new int[2];
int[] wy = new int[2];



void setup(){
  size(600,800);
  db = new SQLite( this, "score.db" );
  
    if ( db.connect() )
    {
        // Check to see if score table exists
        db.query( "SELECT name as \"Name\" FROM SQLITE_MASTER where type=\"table\"" );
        if(!db.next()) db.query( "CREATE TABLE score(ID INT PRIMARY KEY, NAME TEXT, SCORE INT)" );
        
        getScore();

    }
  
  fill(0);
  textSize(40);
}
void draw(){
  if(gamestate==0){
    imageMode(CORNER);
    image(backImg, x, 0);
    image(backImg, x+backImg.width, 0);
    
    x -= 6;
    vy += 0.7;
    y += vy;
    
    if(x == -1800) x = 0;
    for(int i = 0 ;  i < 2; i++){
      imageMode(CENTER);
      image(wallImg, wx[i], wy[i] - (wallImg.height/2+150));
      image(wallImg, wx[i], wy[i] + (wallImg.height/2+150));
      if(wx[i] < 0) {
        wy[i] = (int)random(275, height-275);
        wx[i] = width;
      }
      if(wx[i] == width/2){
        score++;
        highScore = max(score, highScore);
      }
      if( y > height || y < 0 || (abs(width/2-wx[i])<25 && abs(y-wy[i])>150)){
        gamestate = 2;
        name = "";
      }
      wx[i] -= 6;
    }
    image(birdImg, width/2, y);
    text(""+score, width/2-15, 700);
  }
  else if(gamestate == 1){
    imageMode(CENTER);
    image(startImg, width/2, height/2);
    text("High Score: "+highScore, 50, width);
    getScore();
    setScore();
  } else {    
    imageMode(CENTER);
    image(backImg, width/2, height/2);
    text("Please Enter your name:", 50, width);
    text(name, 50, width + 55);
  }
}
void mousePressed(){
  vy = -13.0;
  if(gamestate == 1){
    wx[0] = 600;
    wy[0] = height/2;
    wx[1] = 900;
    wy[1] = 600;
    x = 0 ;
    gamestate = score = 0;
    y = height /2;
  } 
}
void keyPressed(){
  if(gamestate == 2){ 
    if((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) name += key;
    if(key == BACKSPACE || key == DELETE) name = name.substring( 0, name.length()-1 );
    if(key == ENTER || key == RETURN){
        if(name.length() > 0){
          db.query( "insert into score (NAME, SCORE) values (\""+name+"\","+score+")" );
          dbQueryFlag = true;
          gamestate = 1;
        }
    }
  };
}

void setScore(){
    textSize(16);
    highScorePosY = 25;
    for(int i = 0; i < namedb.size(); i++){
        text((i+1)+". "+namedb.get(i)+" - "+scoredb.get(i), 50, width+highScorePosY);
        highScorePosY += 16;
    }
    highScorePosY = 20;
    textSize(40);
}

void getScore(){
    if(dbQueryFlag){
        db.query("select max(score) as \"score\" from score");
      
        while(db.next()){
          highScore = db.getInt("score");
        }
      
        db.query("select * from score order by score desc limit 10");
        
        namedb.clear();
        scoredb.clear();
        
        while (db.next()){
          namedb.add(db.getString("name"));
          scoredb.add(db.getInt("score"));
        }
    }
    dbQueryFlag = false;
}
