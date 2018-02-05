var formatter = new Intl.NumberFormat('en-UK', {
  style: 'currency',
  currency: 'GBP',
  minimumFractionDigits: 2,
});

var updateLabour = function(id) {
  updateDays(id);
  updateLabourTotal();
}

var updateDays = function(id){
  var days = document.getElementsByClassName("single-digit " + id + " days");
  var rates = document.getElementsByClassName(id + " rate");
  var total = 0;
  var sum = 0;
  for (i = 0; i < days.length; i++) {
    var total = total + parseFloat(days[i].value);
    var sum = sum + (parseFloat(days[i].value) * rates[i].value)
  }
  var totalCell = document.getElementById(id + " days");
  totalCell.innerHTML = total;
  var totalCell = document.getElementById(id + " total");
  totalCell.innerHTML = formatter.format(sum);
}
var updateLabourTotal = function() {
  var days = document.getElementsByClassName("table-cell grey-cell days-total");
  var costs = document.getElementsByClassName("table-cell grey-cell cost-total");
  var dayTotal = 0;
  var costTotal = 0;
  for (i = 0; i < costs.length; i++) {
    dayTotal = dayTotal + parseFloat(days[i].innerHTML);
    var price = costs[i].innerHTML;
    var num = price.replace(',', '')
    num = parseFloat(num.replace('£', ''));
    costTotal = costTotal + num;
  }
  var totalCell = document.getElementById("days-total");
  totalCell.innerHTML = dayTotal;
  var totalCell = document.getElementById("cost-total");
  totalCell.innerHTML = formatter.format(costTotal);
}
