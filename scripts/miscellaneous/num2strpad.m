%function str = num2strpad(number,spaces)
% NUM2STRPAD pads the NUMBER with zeros to fill up to a maximum space of SPACES

function str = num2strpad(number,spaces)
if number==0
   digitsOfNumber=0;
else
   digitsOfNumber = floor(log10(number));
end
   zerosToAdd = spaces-digitsOfNumber-1;

if zerosToAdd < 0
    warning('Number is too large for spaces.  Function will return number');
end
a = num2str(zeros(1,zerosToAdd));
a = a(1:3:end);
str = [a num2str(number)];
