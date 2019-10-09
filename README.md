# Godot Geometry Elements
All examples are created using ![Godot Engine](https://github.com/godotengine/godot) v3.0 (or later)
This repository is dedicated to introducing geometry in game development. For this reason some standard methods from mathematical library of Godot Engine are reimplemented in GDScript for purpose of education.

## Examples:
Objective of each example is to illustrate how selected geometry topics can be implemented and used in games.
Each example have 2 versions: <b>starting</b> with framework for implementation and <b>final</b> containing actual implementation.   


### [2d_steering](/final/2d_steering)

Introduction to vector manipulation by implementing basic 2d spacecraft steering using simplified Newtonian physics.

![2d_steering](/assets/examples_animations/2d_steering.gif)

### [projections](/final/projections)
Implementation of projections. Calculation of object spatial relation.

![projections](/assets/examples_animations/projections.gif)

### [bezier_curve](/final/bezier_curve)
Implementation of interactive Bézier curves: linear, quadric and cubic.

![bezier](/assets/examples_animations/bezier.gif)

### [targeting_solution](/final/targeting)

Implementation of two approaches for aiming:
#### Aim approximation used by manoeuvring rockets
#### Predictive aim based on quartic equation solution applied to projectiles with constant speed

![targeting](/assets/examples_animations/targeting.gif)

### [ray_triangle_intersection](/final/ray_triangle_intersection)
Implementation of basic ray tracing based on ray triangle intersection algorithm.

![ray_triangle_intersection](/assets/examples_animations/ray_triangle_intersection.gif)

### [selection_in_3d](/final/selection_in_3d)
Implementation of simple method for selecting points in space.

![selection_in_3d](/assets/examples_animations/selection_in_3d.gif)

## Acknowledgement
Some examples and code fragments are borrowed or inspired by work of Godot Engine community members. Especially:

[Nathan Lovato](https://github.com/NathanLovato) and his [GDquest](http://gdquest.com/)

[Andreas Esau](https://github.com/ndee85) with his [gBot tutorial](https://www.youtube.com/watch?v=WU6MqaodFyw&list=PLPI26-KXCXpBtZGRJizz0cvU88nXB-G14)

[Ivan Skodje](https://github.com/ivanskodje) for his [Godot videos](https://www.youtube.com/channel/UCBHuFCVtZ9vVPkL2VxVHU8A)
