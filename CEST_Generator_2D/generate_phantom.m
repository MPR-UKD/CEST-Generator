%%
% Title: Phantom Image Generation with Random Shapes

% Description: This MATLAB script generates phantom images by creating 
% random shapes within a predefined foreground. The generated shapes 
% include circles, rectangles, curves, and polygons with rounded corners. 
% Each object is randomly placed, dilated, and combined to create a 
% composite phantom image. The script provides a useful tool for testing 
% image processing and analysis techniques on synthetic data.
%%
function [phantom, foreground] = generate_phantom(size, num_objects, full)
   
  if full
      foreground = ones(size);
      phantom = ones(size);
  else
      % Create an empty grayscale image
      phantom = zeros(size);

      % Add foreground to the image
      foreground = add_foreground(phantom);
  end
  
  % Find non-zero elements in the foreground
  [X,Y] = find(foreground ~= 0); 
  
  % Generate random coordinates, sizes, and shapes for the objects
  for i = 1:num_objects
            
    img = zeros(size);
    
    % Generate random coordinates for object
    x1 = X(randi(numel(X)));
    y1 = Y(randi(numel(Y)));
    x2 = X(randi(numel(X)));
    y2 = Y(randi(numel(Y)));

    % Define a list of shapes and randomly select one
    shapes = {'circle', 'rectangle', 'curve', 'polygon'};
    shape = shapes{randi(numel(shapes))};
    
    % Draw the objects on the image
    num = randi(25) + 10;
    for n =1:num
        if strcmp(shape, 'circle')
          % Calculate circle parameters and draw on the image
          r = min([x2 - x1 y2 - y1]) / 2;
          cx = x1 + r;
          cy = y1 + r;
          for x = max([1, cx - r]):min([size(1), cx + r])
            for y = max([1, cy - r]):min([size(2), cy + r])
              if (x - cx)^2 + (y - cy)^2 <= r^2
                img(y, x) = 1;
              end
            end
          end
        elseif strcmp(shape, 'rectangle')
          % Draw a rectangle on the image
          for x = max([1, x1]):min([size(1), x2])
            for y = max([1, y1]):min([size(2), y2])
              img(y, x) = 1;
            end
          end
        elseif strcmp(shape, 'curve')
          % Calculate curve parameters and draw on the image
          start = randi(180);
          end_ = start + randi(90) + 45;
          center = [x1, y1];
          radius = sqrt((x1 - x2)^2 + (y1 - y2)^2) / 2;
          angles = linspace(start, end_, 1000);
          points = [round(center(1) + radius * cosd(angles)); ...
                    round(center(2) + radius * sind(angles))]';
          x1 = x2;
          y1 = y2;
          x2 = randi(size(1));
          y2 = randi(size(2));
          
          % Draw the curve on the image
          for j = 1:length(points)
              try
                  img(round(points(j,1)), round(points(j,2))) = 1;
              catch
              end
          end
        elseif strcmp(shape, 'polygon')
          % Draw a polygon on the image
          img = img + createRandomPolygonsWithRoundCorners(size, 1, 10);
        end
    end
    
        % Ensure img values are binary
    img(img > 1) = 1;
    
    % Create a structuring element for dilation
    se = strel('disk',  randi(5) + 1);
    
    % Perform dilation on the image
    img_dilated = imdilate(img, se);
    phantom = phantom + i * img_dilated(1:size(1),1:size(2));
  end
  
  % Update the phantom image based on the foreground
  phantom(foreground == 0) = 0;
  phantom(foreground == 1) = phantom(foreground == 1) + 1;
end

function mask = add_foreground(mask)
    % Define ellipse parameters
    a = randi(size(mask, 1)) / 4 + size(mask,1) / 4;
    b = randi(size(mask, 1)) / 4+ size(mask,1) / 4;
    cx = randi(size(mask, 1)) / 3 + size(mask,1) / 3;
    cy = randi(size(mask, 1)) / 3 + size(mask,1) / 3;
    angle = randi(size(mask));
    
    % Calculate the points along the ellipse
    num_points = 36;
    theta = linspace(0, 2*pi, num_points);
    x = cx + a * cos(theta) * cos(angle) - b * sin(theta) * sin(angle);
    y = cy + a * cos(theta) * sin(angle) + b * sin(theta) * cos(angle);

    % Create a binary mask of the ellipse
    mask = roipoly(mask, x, y);
    mask(mask > 1) = 1;
end

function mask = randomPolygon(n, max_side)

    % generate random x and y coordinates for the vertices of the polygon
    x = max_side * rand(1, n);
    y = max_side * rand(1, n);

    % Create a binary mask of the polygon
    mask = poly2mask(x,y,max_side,max_side);

end
function mask = createRandomPolygonsWithRoundCorners(imageSize, numPolygons, cornerRadius)

    % Create an empty mask image
    mask = false(imageSize);

    % Loop over the number of polygons to create
    for i = 1:numPolygons
        % Generate random polygon vertices
        polyVerts = rand(2,5) .* imageSize';

        % Create a polygon object with rounded corners
        polygon = polybuffer(polyVerts', 'lines', cornerRadius);
        polygon = rmholes(rmholes(polygon));

        % Fill the polygon in the mask image
        try
            mask = mask + poly2mask(round(polygon.Vertices(:,1)), round(polygon.Vertices(:,2)), imageSize(1), imageSize(2));
        catch
            % Handle exceptions
            b = 2;
        end
    end
    
    % Ensure mask values are binary
    mask(mask > 1) = 1;

end
