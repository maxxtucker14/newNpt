function area = ContourArea(c)
%area = ContourArea(c)
%
%finds the area with a contour
%c is a single x-y pair matrix from insideContour.m
%


c = c(:,2:end);

[val,ind]=min(c(1,:),[],2);
c = circshift(c,[0 -1*(ind-1)]);
[val,ind]=max(c(1,:),[],2);
c1 = c(:,1:ind);            %min->max
c2 = [c(:,ind:end) c(:,1)]; %max->min

%calculate area under each function
dx1 = diff(c1(1,:));
dx2 = abs(diff(c2(1,:)));

%average hieght
y1= mean([c1(2,:) ; circshift(c1(2,:),[0 1])],1);
y1= y1(2:end);  %take off first mean 
y2= mean([c2(2,:) ; circshift(c2(2,:),[0 1])],1);
y2= y2(2:end);  %take off first mean 

%integrate
area1 = sum(dx1.*y1);
area2 = sum(dx2.*y2);

%subtract areas
area = abs(area1-area2);