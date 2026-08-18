// EKIO Website Prototype — Minimal JS for navigation and interactions

// Mobile menu toggle
document.addEventListener('DOMContentLoaded', () => {
    const toggle = document.querySelector('.nav-toggle');
    const links = document.querySelector('.nav-links');
    const lang = document.querySelector('.nav-lang');

    if (toggle) {
        toggle.addEventListener('click', () => {
            const isOpen = links.style.display === 'flex';
            links.style.display = isOpen ? 'none' : 'flex';
            links.style.flexDirection = 'column';
            links.style.position = 'absolute';
            links.style.top = '64px';
            links.style.left = '0';
            links.style.right = '0';
            links.style.background = 'white';
            links.style.padding = '1rem 2rem';
            links.style.borderBottom = '1px solid #E2E8F0';
            links.style.gap = '1rem';

            if (isOpen) {
                links.removeAttribute('style');
            }
        });
    }

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', (e) => {
            const href = anchor.getAttribute('href');
            if (href === '#') return;
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });

    // Navbar background on scroll
    const nav = document.querySelector('.nav');
    if (nav) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 10) {
                nav.style.boxShadow = '0 2px 12px rgba(0,0,0,0.06)';
            } else {
                nav.style.boxShadow = 'none';
            }
        });
    }

    // Simple form submission prevention (prototype only)
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('Form submission — this is a prototype. In the real site, this would send the form data.');
        });
    });
});
