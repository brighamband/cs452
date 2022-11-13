-- Improves formatting
.mode box
.nullvalue NULL
	
-- Create tables and insert values here

-- Create tables
CREATE TABLE User (
	username TEXT PRIMARY KEY,
	firstName TEXT NOT NULL,
	lastName TEXT NOT NULL,
	profilePicUrl TEXT
);

CREATE TABLE Tweet (
	id INTEGER PRIMARY KEY,
	author TEXT NOT NULL,
	timestamp DATE_TIME DEFAULT CURRENT_TIMESTAMP,
	message TEXT NOT NULL,
	imageUrl TEXT,
	videoUrl TEXT,
	isPromoted INTEGER DEFAULT FALSE,
	FOREIGN KEY (author) REFERENCES User (username)
);

CREATE TABLE View (
	viewer TEXT NOT NULL,
	tweetId INTEGER NOT NULL,
	FOREIGN KEY (viewer) REFERENCES User (username),
	FOREIGN KEY (tweetId) REFERENCES Tweet (id),
	PRIMARY KEY (viewer, tweetId)
);

CREATE TABLE Like (
	liker TEXT NOT NULL,
	tweetId INTEGER NOT NULL,
	FOREIGN KEY (liker) REFERENCES User (username),
	FOREIGN KEY (tweetId) REFERENCES Tweet (id),
	PRIMARY KEY (liker, tweetId)
);

CREATE TABLE Retweet (
	id INTEGER PRIMARY KEY,
	author TEXT NOT NULL,
	tweetId INTEGER NOT NULL,
	FOREIGN KEY (author) REFERENCES User (username),
	FOREIGN KEY (tweetId) REFERENCES Tweet (id)
);

CREATE TABLE Follow (
	follower TEXT NOT NULL,
	beingFollowed TEXT NOT NULL,
	FOREIGN KEY (follower) REFERENCES User (username),
	FOREIGN KEY (beingFollowed) REFERENCES User (username),
	PRIMARY KEY (follower, beingFollowed)
);

-- Insert values

INSERT INTO User VALUES 
	("brighamband", "Brigham", "Andersen", "brighamband.com/profile.png"),
	("andrew", "Andrew", "Soulier", "andrew.com/profile.png"),
	("kirby", "Caden", "Kirby", "kirby.com/profile.png"),
	("cookie", "Keaton", "Cook", "cookie.com/profile.png"),
	("knecht", "Cody", "Knecht", NULL);

INSERT INTO Tweet (author, timestamp, message, isPromoted) VALUES
	("brighamband", '2022-10-14 08:00:00', "Hey ya!", FALSE),
	("brighamband", '2022-10-13 10:00:00', "I heart Twitter!", FALSE),
	("andrew", '2022-10-12 22:00:00', "Soulier Studios is here!", TRUE),
	("andrew", '2022-10-07 15:00:00', "Soulier Studios has a coupon!", TRUE),
	("andrew", '2022-10-14 18:00:00', "Follow my company", TRUE),
	("kirby", '2022-10-11 07:00:00', "Let's smash?", FALSE),
	("kirby", '2022-10-07 03:00:00', "Samus is OP", FALSE),
	("cookie", '2022-10-09 09:00:00', "Go BYU! #GoCougars", FALSE),
	("cookie", '2022-10-10 02:00:00', "#GoCougars @ Zions Bank", TRUE);

INSERT INTO View VALUES
	("brighamband", 4),
	("kirby", 4),
	("cookie", 4),
	("knecht", 1),
	("brighamband", 5),
	("kirby", 3);

INSERT INTO Like VALUES
	("brighamband", 4),
	("kirby", 4),
	("cookie", 4),
	("knecht", 1),
	("brighamband", 5),
	("andrew", 9),
	("kirby", 9),
	("brighamband", 3),
	("andrew", 2);

INSERT INTO Retweet (author, tweetId) VALUES 
	("brighamband", 3),
	("brighamband", 5),
	("kirby", 1),
	("cookie", 2),
	("knecht", 7),
	("knecht", 9);

INSERT INTO Follow VALUES 
	('brighamband', 'andrew'),
	('brighamband', 'kirby'),
	('brighamband', 'knecht'),
	('cookie', 'kirby'),
	('kirby', 'cookie'),
	('knecht', 'cookie'),
	('cookie', 'knecht'),
	('andrew', 'brighamband'),
	('cookie', 'brighamband'),
	('kirby', 'brighamband'),
	('knecht', 'brighamband');

-- Display tables
-- .print "Resulting Tables\n"
-- .print "\nUser"
-- SELECT * FROM User;
-- .print "\nTweet"
-- SELECT * FROM Tweet;
-- .print "\nView"
-- SELECT * FROM View;
-- .print "\nLike"
-- SELECT * FROM Like;
-- .print "\nRetweet"
-- SELECT * FROM Retweet;
-- .print "\nFollow"
-- SELECT * FROM Follow;
-- .print "\n\n"

-- Query Construction section:

-- Q1) Count the number of tweets by user. Sort by number of tweets, highest to lowest
.print "\nQ1 - Number of Tweets By User"
SELECT COUNT(*) AS numTweets, author
FROM Tweet
GROUP BY author
ORDER BY numTweets DESC;

-- Q2) Get a list of the top 5 most liked tweets
.print "\nQ2 - Top 5 Most Liked Tweets"
SELECT COUNT(*) AS numLikes, id, author, message
FROM Tweet
	INNER JOIN Like
	ON Tweet.id = Like.tweetId
GROUP BY Tweet.id
ORDER BY numLikes DESC
LIMIT 5;

-- Q3) Which promoted tweet has the most views?
.print "\nQ3 - Promoted Tweet with Most Views"
SELECT COUNT(*) AS numViews, id, author, message
FROM Tweet
	INNER JOIN View
	ON Tweet.id = View.tweetId
WHERE isPromoted = TRUE
GROUP BY Tweet.id
ORDER BY numViews DESC
LIMIT 1; -- Get the top tweet only

-- Q4) Get a list of each user's retweets
.print "\nQ4 - List of Each User's Retweets (Tweets THEY retweeted)"
SELECT Retweet.author AS retweeter, Tweet.id, Tweet.author AS origAuthor, message
FROM Retweet
	INNER JOIN Tweet
	ON Tweet.id = Retweet.tweetId
ORDER BY retweeter;

-- Q5) Get a list of each user's followers
.print "\nQ5 - List of Each User's Followers (Those Following That User)"
SELECT beingFollowed AS userBeingFollowed, follower
FROM Follow
ORDER BY userBeingFollowed;

-- Q6) Count the number tweets containing the hashtag #GoCougars
.print "\nQ6 - Number of Tweets containing #GoCougars"
SELECT COUNT(*) AS numTweets
FROM Tweet
WHERE message LIKE "%#GoCougars%";

-- Q7) Which day of the week do users tweet the most?
.print "\nQ7 - Top Day of the Week for Tweets"
SELECT 
	CASE CAST (strftime('%w', timestamp) AS INTEGER)
  	WHEN 0 THEN 'Sunday'
  	WHEN 1 THEN 'Monday'
	WHEN 2 THEN 'Tuesday'
	WHEN 3 THEN 'Wednesday'
	WHEN 4 THEN 'Thursday'
	WHEN 5 THEN 'Friday'
	ELSE 'Saturday' END AS dayOfWeek, COUNT(timestamp) AS numTweets
FROM Tweet
GROUP BY dayOfWeek
ORDER BY numTweets DESC
LIMIT 1;