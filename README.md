# sea-point-wave-predictor
Shiny app that predicts whether my favorite surf spots around Sea Point will have a wave.

Inputs required:
1. Swell size (x variable)
2. Swell direction (x variable)
3. Wind speed  (x variable)
4. Wind direction (x variable)
5. Tide (x variable)
6. Whether surf spot was good or bad (y variable)
7. Time at which data was collected on spot

Analysis tool: logistic regression

Data source:
Create a server that collects swell, wind and tide data everyday from historical data as well as predicted data. Use this against y variable. 


y variable inputted into the app whenever I drive past and it looks like there is a wave (yes or no) - for now make score out of 3 (bad, average, good)
