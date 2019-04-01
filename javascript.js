var unHighlighted = "#2B5763";
var Highlighted = "#3CA47D";

openTabMain('Alerts','Fissures');
openAlertTab('Fissures');

function copyToClipboard(text){
	var dummy = document.createElement("input");
	document.body.appendChild(dummy);
	dummy.setAttribute('value', text);
	dummy.select();
	document.execCommand("copy");
	document.body.removeChild(dummy);
}

function openTab(tabName) {
	if (tabName=="Buyers") {
		document.getElementById("Buyers").style.display = "block";
		document.getElementById("Sellers").style.display = "none";
		document.getElementById("BuyersButton").style.backgroundColor = Highlighted;
		document.getElementById("SellersButton").style.backgroundColor = unHighlighted;
	}else {
		document.getElementById("Sellers").style.display = "block";
		document.getElementById("Buyers").style.display = "none";
		document.getElementById("SellersButton").style.backgroundColor = Highlighted;
		document.getElementById("BuyersButton").style.backgroundColor = unHighlighted;
	}
}

function openAlertTab(tabName) {
	document.getElementById("AlertsAlerts").style.display = "none";
	document.getElementById("Fissures").style.display = "none";
	document.getElementById("Invasions").style.display = "none";
	document.getElementById("AlertsAlertsButton").style.backgroundColor = unHighlighted;
	document.getElementById("FissuresButton").style.backgroundColor = unHighlighted;
	document.getElementById("InvasionsButton").style.backgroundColor = unHighlighted;
	document.getElementById("AlertTabs").style.display = "block";
	if (tabName=="Fissures") {
		location.href='myapp://Fissures';
		document.getElementById("Fissures").style.display = "block";
		document.getElementById("FissuresButton").style.backgroundColor = Highlighted;
	}else if (tabName=="Invasions") {
		location.href='myapp://Invasions';
		document.getElementById("Invasions").style.display = "block";
		document.getElementById("InvasionsButton").style.backgroundColor = Highlighted;
	}else {
		location.href='myapp://Alerts';
		document.getElementById("AlertsAlerts").style.display = "block";
		document.getElementById("AlertsAlertsButton").style.backgroundColor = Highlighted;
	}
}

function openRelicTab(tabName) {
	document.getElementById("RelicTabs").style.display = "block";
	if (tabName=="Missions") {
		location.href='myapp://Missions';
		document.getElementById("Missions").style.display = "block";
		document.getElementById("Rewards").style.display = "none";
		document.getElementById("MissionsButton").style.backgroundColor = Highlighted;
		document.getElementById("RewardsButton").style.backgroundColor = unHighlighted;
	}else {
		location.href='myapp://Rewards';
		document.getElementById("Rewards").style.display = "block";
		document.getElementById("Missions").style.display = "none";
		document.getElementById("RewardsButton").style.backgroundColor = Highlighted;
		document.getElementById("MissionsButton").style.backgroundColor = unHighlighted;
	}
}

function openTabMain(tabName,tabName2) {
	document.getElementById("AlertTabs").style.display = "none";
	document.getElementById("RelicTabs").style.display = "none";
	document.getElementById("Alerts").style.display = "none";
	document.getElementById("Missions").style.display = "none";
	document.getElementById("Rewards").style.display = "none";
	document.getElementById("Rivens").style.display = "none";
	document.getElementById("Prices").style.display = "none";
	document.getElementById("AlertsButton").style.backgroundColor = unHighlighted;
	document.getElementById("RelicsButton").style.backgroundColor = unHighlighted;
	document.getElementById("RivensButton").style.backgroundColor = unHighlighted;
	document.getElementById("PricesButton").style.backgroundColor = unHighlighted;
	if (tabName=="Alerts"){
		document.getElementById("Alerts").style.display = "block";
		document.getElementById("AlertsButton").style.backgroundColor = Highlighted;
		document.getElementById("HugeIMG").style.top = "75px";
		openAlertTab(tabName2);
	}else if (tabName=="Relics"){
		document.getElementById("RelicsButton").style.backgroundColor = Highlighted;
		document.getElementById("HugeIMG").style.top = "110px";
		openRelicTab(tabName2);
	}else if (tabName=="Rivens"){
		location.href='myapp://Rivens';
		document.getElementById("Rivens").style.display = "block";
		document.getElementById("RivensButton").style.backgroundColor = Highlighted;
	}else{
		location.href='myapp://Prices';
		document.getElementById("Prices").style.display = "block";
		document.getElementById("PricesButton").style.backgroundColor = Highlighted;
		openTab(tabName2);
	} 
}
function ResizeDivs(x,h) {
	elements = document.getElementsByClassName(x);
	for (var i = 0; i < elements.length; i++) {
		elements[i].style.height = h + "px";
	}
	h = h - 30;
	document.getElementById("Rewards").style.height = h + "px";
	h = h - 40;
	document.getElementById("Missions").style.height = h + "px";
}
function ShowHugeIMG(x) {
    document.getElementById("HugeIMG").style.display = "block";
    document.getElementById("HugeIMGactual").src = x;
}
function HideHugeIMG() {
    document.getElementById("HugeIMG").style.display = "none";
}