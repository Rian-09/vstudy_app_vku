/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          yellow: '#c9f36a',
          lime: '#c9f36a',
          blue: '#6b5cc7',
          purple: '#6b5cc7',
          lavender: '#f0edff',
          red: '#d64545',
          ink: '#302c46',
          muted: '#77748c',
          surface: '#f5f4fa',
        },
      },
      boxShadow: {
        panel: '0 12px 36px rgba(64, 53, 117, 0.12)',
      },
    },
  },
  plugins: [],
};
