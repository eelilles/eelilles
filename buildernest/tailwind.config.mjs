/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        // Primary: Deep forest with slate-blue undertones
        forest: {
          50: '#f3f6f5',
          100: '#e1e8e5',
          200: '#c5d2cd',
          300: '#9db4ab',
          400: '#729186',
          500: '#56766b',
          600: '#445e55',
          700: '#394d47',
          800: '#31403b',
          900: '#2b3633',
          950: '#161e1b'
        },
        // Secondary: Warm wood/amber accent
        amber: {
          50: '#fefbf3',
          100: '#fdf4de',
          200: '#fae6bc',
          300: '#f6d38f',
          400: '#f1b84f',
          500: '#eda02c',
          600: '#de8420',
          700: '#b8641c',
          800: '#944f1f',
          900: '#78421d',
          950: '#41210c'
        },
        // Neutrals: Warm grays (stone-based)
        stone: {
          50: '#fafaf9',
          100: '#f5f5f4',
          200: '#e7e5e4',
          300: '#d6d3d1',
          400: '#a8a29e',
          500: '#78716c',
          600: '#57534e',
          700: '#44403c',
          800: '#292524',
          900: '#1c1917',
          950: '#0c0a09'
        },
        // Background: Off-white with subtle warmth
        cream: {
          50: '#fefdfb',
          100: '#fdfbf7',
          200: '#faf6ef'
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
        heading: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'Monaco', 'Consolas', 'monospace']
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1.5' }],
        sm: ['0.875rem', { lineHeight: '1.5715' }],
        base: ['1rem', { lineHeight: '1.75' }],
        lg: ['1.125rem', { lineHeight: '1.75' }],
        xl: ['1.25rem', { lineHeight: '1.6' }],
        '2xl': ['1.5rem', { lineHeight: '1.4' }],
        '3xl': ['1.875rem', { lineHeight: '1.3' }],
        '4xl': ['2.25rem', { lineHeight: '1.2' }],
        '5xl': ['3rem', { lineHeight: '1.15' }]
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem'
      },
      borderRadius: {
        '4xl': '2rem'
      },
      boxShadow: {
        'soft': '0 2px 8px -2px rgba(0, 0, 0, 0.05), 0 4px 16px -4px rgba(0, 0, 0, 0.08)',
        'lifted': '0 4px 12px -2px rgba(0, 0, 0, 0.08), 0 8px 24px -4px rgba(0, 0, 0, 0.12)'
      }
    }
  },
  plugins: []
};
