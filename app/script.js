// This script adds interactivity to the webpage, including dark mode toggle, smooth scrolling, a testimonial slider, and form validation.
// Ensure the DOM is fully loaded before executing the script
document.addEventListener("DOMContentLoaded", function() {
    
    // Dark Mode Toggle
    const toggleButton = document.createElement("button");
    toggleButton.textContent = "🌙 Toggle Dark Mode";
    toggleButton.style.position = "fixed";
    toggleButton.style.top = "10px";
    toggleButton.style.right = "10px";
    toggleButton.style.padding = "10px";
    toggleButton.style.background = "#ff6600";
    toggleButton.style.color = "white";
    toggleButton.style.border = "none";
    toggleButton.style.cursor = "pointer";
    document.body.appendChild(toggleButton);

    toggleButton.addEventListener("click", function() {
        document.body.classList.toggle("dark-mode");
    });

    // Smooth Scrolling for Navigation Links
    document.querySelectorAll("nav ul li a").forEach(anchor => {
        anchor.addEventListener("click", function(e) {
            e.preventDefault();
            const targetId = this.getAttribute("href").substring(1);
            const targetSection = document.getElementById(targetId);
            targetSection.scrollIntoView({ behavior: "smooth" });
        });
    });

    // Testimonial Slider
    const testimonials = document.querySelectorAll(".testimonial");
    let currentTestimonial = 0;

    function showTestimonial(index) {
        testimonials.forEach((testimonial, i) => {
            testimonial.style.display = i === index ? "block" : "none";
        });
    }

    showTestimonial(currentTestimonial);

    setInterval(() => {
        currentTestimonial = (currentTestimonial + 1) % testimonials.length;
        showTestimonial(currentTestimonial);
    }, 5000); // Changes testimonial every 5 seconds

    // Contact Form Validation
    const form = document.querySelector("form");
    form.addEventListener("submit", function(event) {
        const name = document.getElementById("name").value.trim();
        const email = document.getElementById("email").value.trim();
        const message = document.getElementById("message").value.trim();

        if (name === "" || email === "" || message === "") {
            alert("All fields must be filled out.");
            event.preventDefault();
        } else if (!email.includes("@")) {
            alert("Please enter a valid email address.");
            event.preventDefault();
        }
    });
});