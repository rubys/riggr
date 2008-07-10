// Parse an HTML5-liberalized version of RFC 3339 datetime values
Date.parseRFC3339 = function (string) {
    var date=new Date(0);
    var match = string.match(/(\d{4})-(\d\d)-(\d\d)\s*(?:[\sT]\s*(\d\d):(\d\d)(?::(\d\d))?(\.\d*)?\s*(Z|([-+])(\d\d):(\d\d))?)?/);
    if (!match) return;
    if (match[2]) match[2]--;
    if (match[7]) match[7] = (match[7]+'000').substring(1,4);
    var field = [null,'FullYear','Month','Date','Hours','Minutes','Seconds','Milliseconds'];
    for (var i=1; i<=7; i++) if (match[i]) date['setUTC'+field[i]](match[i]);
    if (match[9]) date.setTime(date.getTime()+
        (match[9]=='-'?1:-1)*(match[10]*3600000+match[11]*60000) );
    return date.getTime();
}

// Localize the display of <time> elements
function localizeDates() {
  var xhtml = "http://www.w3.org/1999/xhtml";
  var times = document.getElementsByTagNameNS(xhtml,'time');
  var sections = document.getElementsByTagNameNS(xhtml,'section');
  var lastdate = '';
  var now = new Date();
  var top = sections[0];
  var snapshot = new Array();
  for (var i=0; i<sections.length; i++) snapshot[i] = sections[i];

  for (var i=0; i<times.length; i++) {
    if (times[i].getAttribute('title') == "GMT") {
      var date = new Date(Date.parseRFC3339(times[i].getAttribute('datetime')));
      if (!date.getTime()) return;

      // replace title attribute and textContent value with localized versions
      if (times[i].textContent.length < 10 || now-date < 86400000) {
        // time only
        times[i].setAttribute('title', date.toUTCString());
        times[i].textContent = date.toLocaleTimeString();
      } else if (times[i].getAttribute('datetime').length <= 16) {
        // date only
        times[i].removeAttribute('title');
        times[i].textContent = date.toLocaleDateString();
      } else {
        // full datetime
        times[i].setAttribute('title', times[i].textContent + ' GMT');
        times[i].textContent = date.toLocaleString();
      }

      // insert/remove date headers to reflect date in local time zone
      var parent = times[i];
      while (parent && parent.nodeName != 'article') parent=parent.parentNode;
      if (parent && parent.parentNode.nodeName=='section') {
        var displayDate = date.toLocaleDateString();
        if (displayDate != lastdate) {
          section = document.createElementNS(xhtml, 'section');
          var header = document.createElementNS(xhtml, 'header');
          var h2 = document.createElementNS(xhtml, 'h2');
          var time = document.createElementNS(xhtml, 'time');
          var datetime = times[i].getAttribute('datetime').substring(0,10);
          time.setAttribute('datetime',datetime);
          time.appendChild(document.createTextNode(displayDate));
          h2.appendChild(time);
          header.appendChild(h2);
          section.appendChild(header);
          lastdate = displayDate;
          top.parentNode.insertBefore(section, top);
        }
        section.appendChild(parent);
      }
    }
  }

  // remove original sections
  for (var i=0; i<snapshot.length; i++) {
    snapshot[i].parentNode.removeChild(snapshot[i]);
  }
}

if (document.addEventListener) {
  document.addEventListener("DOMContentLoaded", localizeDates, false);
}

// allow IE to recognize HTMl5 elements
if (!document.createElementNS) {
  document.createElement('article');
  document.createElement('aside');
  document.createElement('footer');
  document.createElement('header');
  document.createElement('nav');
  document.createElement('time');
}
