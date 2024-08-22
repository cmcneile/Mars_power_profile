% Load your data from Excel
[num, ~, ~] = xlsread('MATLAB_MARS_training.xlsx');
decentration = num(:, 1); % Extract decentration values
power_data = num(:, 2:end); % Extract power measurements

% Preallocate space for MARS models
num_lens_powers = size(power_data, 2);
models = cell(1, num_lens_powers);

% Generate the range of lens powers
min_lens_power = -10;  % Adjust this according to your data
max_lens_power = -1;   % Adjust this according to your data
step_lens_power = 1;   % Adjust this according to your data
lens_powers = min_lens_power:step_lens_power:max_lens_power;

% Fit MARS regression models for each lens power
for i = 1:num_lens_powers
    models{i} = fitrtree(decentration, power_data(:, i), 'MinLeafSize', 5);
end

% Prompt user to input the new overall lens power for prediction
new_lens_power = input('Enter the overall lens power for prediction: ');

% Predicted power curve for the new lens power
if new_lens_power < min(lens_powers)
    fprintf('New lens power is below the range of measured powers.\n');
elseif new_lens_power > max(lens_powers)
    fprintf('New lens power is above the range of measured powers.\n');
else
    % Find the index of the nearest measured lens power for prediction
    [~, idx] = min(abs(lens_powers - new_lens_power));
    
    % Predict the power curve for the nearest measured lens power
    predicted_power_curve = predict(models{idx}, decentration);
    
    % Save predicted values to CSV file
    output_data = [decentration, predicted_power_curve];
    csvwrite('predicted_power_curve.csv', output_data);
    
    % Visualization
    plot(decentration, predicted_power_curve, 'LineWidth', 2);
    xlabel('Decentration');
    ylabel('Power');
    title(['Predicted Power Curve for Overall Lens Power: ', num2str(new_lens_power)]);
    
    % Save the plot as a PNG image
    saveas(gcf, 'predicted_power_curve_plot.png');
end