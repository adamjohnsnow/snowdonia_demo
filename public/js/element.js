var formatter = new Intl.NumberFormat('en-UK', {
  style: 'currency',
  currency: 'GBP',
  minimumFractionDigits: 2,
});

var updateCost = function(id) {
  var qty = document.getElementById(id + " units").value;
  var price = document.getElementById(id + " price").innerHTML;
  var num = parseFloat(price.replace('£', ''));
  var element = document.getElementById(id + " cost");
  element.innerHTML = formatter.format(qty * num);
  if (document.getElementById("cost-total")) { updateTotal(); }
}

var updateTotal = function(){
  var costs = document.getElementsByClassName("table-cell cost");
  var total = 0
  for (i = 0; i < costs.length; i++) {
    var price = costs[i].innerHTML;
    var num =price.replace(',', '')
    num = parseFloat(num.replace('£', ''));
    total = total + num;
  }
  var totalCell = document.getElementById("cost-total");
  totalCell.innerHTML = formatter.format(total);
}

var updateLabour = function(type) {
  var days = document.getElementsByName(type);
  var cost = document.getElementsByName(type + '_cost');
  var total = document.getElementsByClassName("table-cell " + type + "-total");
  total[0].innerHTML = formatter.format(days[0].value * cost[0].value);
  updateLabourTotal();
}

var updateLabourTotal = function() {
  var days = document.getElementsByClassName("double-digit lab-day");
  var costs = document.getElementsByClassName("double-digit lab-cost");
  var dayTotal = 0;
  var costTotal = 0;
  for (i = 0; i < costs.length; i++) {
    var price = costs[i].value;
    var day = parseFloat(days[i].value);
    dayTotal = dayTotal + day;
    costTotal = costTotal + (price * day);
  }
  var totalCell = document.getElementById("day-total");
  totalCell.innerHTML = dayTotal;
  if (document.getElementById("lab-total")) {
    document.getElementById("lab-total").innerHTML = formatter.format(costTotal);
  }
}

var reorderUp = function(id) {
  if ( document.getElementById(id + ' order').value > 1 ) {
    var list = document.getElementById('materials-list')
    var moveRow = document.getElementById(id + '-row');
    var rowOrder = moveRow.childNodes[1].childNodes[7];
    rowOrder.value = parseInt(rowOrder.value) - 1;
    moveUp(moveRow);
  }
}
var moveUp = function(moveRow) {
  var index = Array.prototype.indexOf.call(list.children, moveRow);
  list.insertBefore(moveRow, list.childNodes[(index * 2) - 3])
  rowOrder = list.childNodes[(index * 2) - 2].childNodes[1].childNodes[7];
  rowOrder.value = parseInt(rowOrder.value) + 1;
  list.insertBefore(list.childNodes[(index * 2) - 2], list.childNodes[(index * 2) + 2])
}

var reorderDown = function(id) {
  var list = document.getElementById('materials-list');
  var index = Array.prototype.indexOf.call(list.children, moveRow);
  if ((index * 2) + 7 < list.childNodes.length) {
    var moveRow = document.getElementById(id + '-row');
    var rowOrder = moveRow.childNodes[1].childNodes[7];
    rowOrder.value = parseInt(rowOrder.value) + 1;
    moveDown(moveRow, index);
  }
}

var moveDown = function(moveRow, index) {
  list.insertBefore(moveRow, list.childNodes[(index * 2) + 5])
  rowOrder = list.childNodes[(index * 2) + 5].childNodes[1].childNodes[7];
  rowOrder.value = parseInt(rowOrder.value) - 1;
  list.insertBefore(list.childNodes[(index * 2) + 5], list.childNodes[(index * 2) + 1])
  console.log(list.childNodes)
}