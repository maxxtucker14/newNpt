function [vert_degrees , horiz_degrees] = pixel2degree(vert_pixel, horiz_pixel)
%function [vert_degrees , horiz_degrees] = pixel2degree(vertical_pixel, horiz_pixel)
%
%this function changes input eye data from pixels to degrees
%it assumes a 12"x16" screen 57 cm from the monkey.
%
%this function changes pixel locations on the screen to the corresponding 
%location in degrees.  
%If a change in pixels is inputted, the center pixel location should be added
%to it to get the correct result.




%constants to convert from pixels to degrees
	screen_width=16;
	screen_height=11.9375;
	movie_width=800;
	movie_height=600;
	movie_distance=57;	%monkey is 57 cm from movie

%change data from pixels to degrees
   vert_degrees = (atan(((vert_pixel-movie_height/2)*screen_height*2.54/movie_height)/movie_distance))*180/pi;
   horiz_degrees = (atan(((horiz_pixel-movie_width/2)*screen_width*2.54/movie_width)/movie_distance))*180/pi;
   
   
   
   
   
   