(()=>{function a(){document.getElementById("sidebar_canvas_overlay").classList.add("hidden")}function d(){document.getElementById("sidebar_canvas_overlay").classList.remove("hidden")}function s(){document.getElementById("sidebar").classList.add("close")}function c(){document.getElementById("sidebar").classList.remove("close")}window.addEventListener("DOMContentLoaded",function(){document.getElementById("sidebar_btn").addEventListener("click",function(){d(),c()}),document.getElementById("sidebar_canvas_overlay").addEventListener("click",function(){a(),s()});let t=document.getElementById("dark_mode_btn"),n=document.getElementById("light_mode_btn");t.addEventListener("click",function(){document.documentElement.setAttribute("data-theme","dark"),localStorage.theme="dark"}),n.addEventListener("click",function(){document.documentElement.setAttribute("data-theme","light"),localStorage.theme="light"})});})();
