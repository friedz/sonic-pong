# Currently supported platforms
Linux

# What is this?

SonicPong currently is a final project for a university course and is **still in its development phase**. It may or may not be maintained by us further after February 2018.

Screenshot here.

# Yeah, but what exactly is the project?

SonicPong aims to become an audio game version of the classic game Pong. It will have a GUI and AUI for gaming. Currently we're working on supporting one audio and one visual player or two visual players. Somewhere in the future we're hoping to find the time and implement a version for two audio players. and some extra features.

# Pong as audio game, how does that work?

Our current approach is the following:
+ The ball's position on the y-axis will be represented by its position in the stereo spectrum relative to the paddle of an audio player
+ The balls's position on the x-axis will be represented by the level of pitch in some way

# What's the current state of development?
We're using the programming language Ruby, QML, Qt5 and SuperCollider for this. At the moment, the most promising approach is the latest commit on branch `scruby` (we're not actually using scruby!). It currently works on Linux only and uses Linux' audio server JACK.

# Installation
## Requirements
+ Linux
+ Ruby 2.4.0 (or later),
+ [Ruby-QML](https://github.com/seanchas116/ruby-qml),
+ Qt5,
+ SuperCollider.

Also, audio server _JACK must be running_.

## Linux
There currently is no Gem-file (sorry, but we're not not quite there, yet), so clone the repository to your local drive and start\\
`ruby pathToYourClonedRepository/pong.rb`\\
from the command line or just `cd` into your cloned repository and start with\\
`ruby ./pong.rb`.

# Usage
## Right paddle
+ Move up (`up-arrow`) and down (`down-arrow`) along the y-axis
+ If you miss the incoming ball, your opponent gains a point

## Left Paddle
+ Move up (`w`) and down (`s`) along the y-axis
+ If you miss the incoming ball, your opponent gains a point

## Ball
+ The ball is to be hit, so it won't leave the court on left or right side
+ If it does, your opponent will gain a point
+ The ball will bounce off the upper and lower sides of the court
+ In this case the ball will be served from the middle
+ Currently this will go on indefinitely

# How is this relevant for teaching high school students?
Remember, this is project is meant to have educational aspects! So, single methods, especially `class Ball` and even more so the test classes, could be bold examples for analyzing in class. We see the project fit for teaching soft skills in software project management as well as, in terms of content, some introductory concepts of object-oriented programming. The project itself would be suitable as a final project at the end of a unit for gaining practical knowledge regarding previously discussed content of the curriculum.
