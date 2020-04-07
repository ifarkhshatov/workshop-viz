console.log("index.js loaded")

// Getting info from server
Shiny.addCustomMessageHandler("countriesStats", function(data) {
  dailyChart(data[0], data[1][0])
}) 

function dataPreparation(data, countries, type) {
  var chartData = [];
  for (var country = 0; country < Object.keys(data).length; country++){
    chartData[country] = {
      data: data[countries[country]].map(country => country[type]),
      label: countries[country],
      fill: false
    }

  }
  return(chartData)
}

function dailyChart(data, type) {

  $(".countries-stats").empty();
  $(".countries-stats").append(
    '<canvas id="countries-stats"></canvas>'
  );


  // get canvas 
  var canvas = document.getElementById("countries-stats");
  // get the list of countries
  var countries = Object.keys(data);
  // return date from any array (they are equal)
  var labels = data[countries[0]].map(country => country.date);
  // apply function for returning dataset
  var datasets =  dataPreparation(data, countries, type);
  new Chart(canvas, {
    type: 'line',
    data: {
      labels,
      datasets
    },
    options: {
      plugins: {
        colorschemes: {
          scheme: 'brewer.Paired12'
       }
      }
    }
  })
  
}

