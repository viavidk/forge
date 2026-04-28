#!/bin/bash
# lib/14-tailwind.sh — tailwind.config.js + runtime partial

generate_tailwind_config() {
  local ds="$1"
  local out="$2"

  case "$ds" in
    vercel)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#000000',
        'ds-bg-dark':  '#000000',
        'ds-bg-light': '#ffffff',
        'ds-tx-dark':  '#ffffff',
        'ds-tx-light': '#000000',
        'ds-surface':  '#111111',
        'ds-muted':    '#888888',
        'ds-border':   '#333333',
      },
      fontFamily: {
        'ds-sans': ['"Geist"', '"Inter"', 'system-ui', 'sans-serif'],
        'ds-mono': ['"Geist Mono"', '"JetBrains Mono"', 'monospace'],
      },
      borderRadius: { 'ds': '6px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    linear.app)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#5e6ad2',
        'ds-bg-dark':  '#0f0f11',
        'ds-bg-light': '#f7f7f8',
        'ds-tx-dark':  '#f2f2f2',
        'ds-tx-light': '#1a1a2e',
        'ds-surface':  '#18181d',
        'ds-muted':    '#6e6e82',
        'ds-border':   '#252530',
      },
      fontFamily: {
        'ds-sans': ['"Inter"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '8px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    stripe)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#635bff',
        'ds-bg-dark':  '#09080f',
        'ds-bg-light': '#f6f9fc',
        'ds-tx-dark':  '#e8e4ff',
        'ds-tx-light': '#0a2540',
        'ds-surface':  '#1a1730',
        'ds-muted':    '#8792a2',
        'ds-border':   '#2a2550',
      },
      fontFamily: {
        'ds-sans': ['"Sohne"', '"Inter"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '6px', 'ds-pill': '999px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    notion)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#2eaadc',
        'ds-bg-dark':  '#191919',
        'ds-bg-light': '#ffffff',
        'ds-tx-dark':  '#e8e8e8',
        'ds-tx-light': '#37352f',
        'ds-surface':  '#252525',
        'ds-muted':    '#9b9a97',
        'ds-border':   '#383838',
      },
      fontFamily: {
        'ds-sans':  ['"Inter"', 'system-ui', 'sans-serif'],
        'ds-serif': ['"Georgia"', 'serif'],
      },
      borderRadius: { 'ds': '4px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    supabase)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#3ecf8e',
        'ds-bg-dark':  '#0d1117',
        'ds-bg-light': '#f8fafc',
        'ds-tx-dark':  '#ededed',
        'ds-tx-light': '#1c1c1e',
        'ds-surface':  '#161b22',
        'ds-muted':    '#6e7681',
        'ds-border':   '#21262d',
      },
      fontFamily: {
        'ds-sans': ['"Inter"', 'system-ui', 'sans-serif'],
        'ds-mono': ['"JetBrains Mono"', 'monospace'],
      },
      borderRadius: { 'ds': '6px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    spotify)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#1db954',
        'ds-bg-dark':  '#121212',
        'ds-bg-light': '#f4f4f4',
        'ds-tx-dark':  '#ffffff',
        'ds-tx-light': '#000000',
        'ds-surface':  '#282828',
        'ds-muted':    '#b3b3b3',
        'ds-border':   '#3e3e3e',
      },
      fontFamily: {
        'ds-sans': ['"Circular"', '"Montserrat"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '4px', 'ds-pill': '500px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    figma)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#0acf83',
        'ds-accent-2': '#a259ff',
        'ds-accent-3': '#ff7262',
        'ds-accent-4': '#1abcfe',
        'ds-bg-dark':  '#1e1e1e',
        'ds-bg-light': '#f5f5f5',
        'ds-tx-dark':  '#e6e6e6',
        'ds-tx-light': '#1e1e1e',
        'ds-surface':  '#2c2c2c',
        'ds-muted':    '#8c8c8c',
        'ds-border':   '#3e3e3e',
      },
      fontFamily: {
        'ds-sans': ['"Inter"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '8px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    tesla)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#e82127',
        'ds-bg-dark':  '#000000',
        'ds-bg-light': '#ffffff',
        'ds-tx-dark':  '#ffffff',
        'ds-tx-light': '#171a20',
        'ds-surface':  '#1a1a1a',
        'ds-muted':    '#666666',
        'ds-border':   '#333333',
      },
      fontFamily: {
        'ds-sans': ['"Gotham"', '"Roboto"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '0px', 'ds-btn': '4px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    shopify)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#96bf48',
        'ds-bg-dark':  '#0a0b0d',
        'ds-bg-light': '#f6f6f7',
        'ds-tx-dark':  '#e3e3e3',
        'ds-tx-light': '#202223',
        'ds-surface':  '#1a1c1e',
        'ds-muted':    '#6d7175',
        'ds-border':   '#2b2e30',
      },
      fontFamily: {
        'ds-sans': ['"ShopifySans"', '"Inter"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '8px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    cursor)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#7c5cfc',
        'ds-accent-2': '#00d4ff',
        'ds-bg-dark':  '#0c0c0f',
        'ds-bg-light': '#f0f0f5',
        'ds-tx-dark':  '#e8e8f0',
        'ds-tx-light': '#0c0c0f',
        'ds-surface':  '#16161c',
        'ds-muted':    '#6b6b80',
        'ds-border':   '#222230',
      },
      fontFamily: {
        'ds-sans': ['"Geist"', '"Inter"', 'system-ui', 'sans-serif'],
        'ds-mono': ['"Geist Mono"', 'monospace'],
      },
      borderRadius: { 'ds': '8px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    raycast)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.php','./public/**/*.php','./public/assets/js/**/*.js'],
  theme: {
    extend: {
      colors: {
        'ds-accent':   '#ff6363',
        'ds-accent-2': '#bf5af2',
        'ds-accent-3': '#ff9f0a',
        'ds-bg-dark':  '#111113',
        'ds-bg-light': '#f2f2f5',
        'ds-tx-dark':  '#eeeeee',
        'ds-tx-light': '#111113',
        'ds-surface':  '#1c1c1f',
        'ds-muted':    '#7b7b8a',
        'ds-border':   '#2a2a30',
      },
      fontFamily: {
        'ds-sans': ['"Inter"', 'system-ui', 'sans-serif'],
      },
      borderRadius: { 'ds': '10px', 'ds-lg': '14px' },
    },
  },
  plugins: [],
};
TWEOF
      ;;
    *)
      # Apple (default)
      cat > "$out" << 'TWEOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.php',
    './public/**/*.php',
    './public/assets/js/**/*.js',
  ],
  theme: {
    extend: {
      colors: {
        'apple-blue':      '#0071e3',
        'apple-link':      '#0066cc',
        'apple-link-dark': '#2997ff',
        'apple-gray':      '#f5f5f7',
        'apple-dark':      '#1d1d1f',
        'apple-dark-card': '#272729',
      },
      borderRadius: {
        'pill': '980px',
      },
      fontFamily: {
        'sf-display': ['"SF Pro Display"', '"Helvetica Neue"', 'Helvetica', 'Arial', 'sans-serif'],
        'sf-text':    ['"SF Pro Text"',    '"Helvetica Neue"', 'Helvetica', 'Arial', 'sans-serif'],
      },
      lineHeight: {
        'hero':    '1.07',
        'section': '1.10',
        'tile':    '1.14',
        'card':    '1.19',
      },
      letterSpacing: {
        'apple-hero': '-0.28px',
        'apple-body': '-0.374px',
        'apple-sm':   '-0.224px',
        'apple-xs':   '-0.12px',
      },
    },
  },
  plugins: [],
};
TWEOF
      ;;
  esac
}

generate_tailwind_partial() {
  local ds="$1"
  local out="$2"

  case "$ds" in
    vercel|cursor)
      cat > "$out" << 'PEOF'
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'ds-accent':'#000000','ds-bg-dark':'#000000','ds-bg-light':'#ffffff',
          'ds-tx-dark':'#ffffff','ds-tx-light':'#000000','ds-surface':'#111111',
          'ds-muted':'#888888','ds-border':'#333333'
        },
        fontFamily: { 'ds-sans':['Geist','Inter','system-ui','sans-serif'], 'ds-mono':['"Geist Mono"','monospace'] },
        borderRadius: { 'ds':'6px' }
      }
    }
  }
</script>
<style>:root{font-family:'Geist',system-ui,sans-serif;-webkit-font-smoothing:antialiased}</style>
PEOF
      ;;
    linear.app)
      cat > "$out" << 'PEOF'
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'ds-accent':'#5e6ad2','ds-bg-dark':'#0f0f11','ds-bg-light':'#f7f7f8',
          'ds-tx-dark':'#f2f2f2','ds-tx-light':'#1a1a2e','ds-surface':'#18181d',
          'ds-muted':'#6e6e82','ds-border':'#252530'
        },
        fontFamily: { 'ds-sans':['Inter','system-ui','sans-serif'] },
        borderRadius: { 'ds':'8px' }
      }
    }
  }
</script>
<style>:root{font-family:'Inter',system-ui,sans-serif;-webkit-font-smoothing:antialiased}</style>
PEOF
      ;;
    stripe)
      cat > "$out" << 'PEOF'
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'ds-accent':'#635bff','ds-bg-dark':'#0a2540','ds-bg-light':'#ffffff',
          'ds-tx-dark':'#ffffff','ds-tx-light':'#0a2540','ds-surface':'#1a3654',
          'ds-muted':'#425466','ds-border':'#e3e8ee'
        },
        fontFamily: { 'ds-sans':['Inter','system-ui','sans-serif'] },
        borderRadius: { 'ds':'8px' }
      }
    }
  }
</script>
<style>:root{font-family:'Inter',system-ui,sans-serif;-webkit-font-smoothing:antialiased;font-weight:300}</style>
PEOF
      ;;
    shopify)
      cat > "$out" << 'PEOF'
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'ds-accent':'#96bf48','ds-bg-dark':'#0b0c10','ds-bg-light':'#ffffff',
          'ds-tx-dark':'#f5f5f5','ds-tx-light':'#1a1a1a','ds-surface':'#16181d',
          'ds-muted':'#6b7280','ds-border':'#262830'
        },
        borderRadius: { 'ds':'8px' }
      }
    }
  }
</script>
<style>:root{-webkit-font-smoothing:antialiased}</style>
PEOF
      ;;
    notion|supabase|spotify|figma|tesla|raycast)
      cat > "$out" << 'PEOF'
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'ds-accent':'#6366f1','ds-bg-dark':'#0f0f14','ds-bg-light':'#f9fafb',
          'ds-tx-dark':'#f3f4f6','ds-tx-light':'#111827','ds-surface':'#1a1a22',
          'ds-muted':'#6b7280','ds-border':'#262630'
        },
        borderRadius: { 'ds':'8px' }
      }
    }
  }
</script>
<style>:root{-webkit-font-smoothing:antialiased}</style>
PEOF
      ;;
    *)
      # Apple default
      cat > "$out" << 'PEOF'
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        colors: {
          'apple-blue':'#0071e3','apple-link':'#0066cc','apple-link-dark':'#2997ff',
          'apple-gray':'#f5f5f7','apple-dark':'#1d1d1f','apple-dark-card':'#272729'
        },
        borderRadius: { 'pill':'980px' },
        fontFamily: {
          'sf-display':['SF Pro Display','Helvetica Neue','Helvetica','Arial','sans-serif'],
          'sf-text':['SF Pro Text','Helvetica Neue','Helvetica','Arial','sans-serif']
        }
      }
    }
  }
</script>
<style>
  :root{font-family:'SF Pro Text','Helvetica Neue',Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}
  h1,h2,h3,h4,h5,h6{font-family:'SF Pro Display','Helvetica Neue',Helvetica,Arial,sans-serif}
</style>
PEOF
      ;;
  esac
}

install_tailwind() {
  mkdir -p "$PROJECT/app/views/partials"

  if [ "$USE_TAILWIND" = "Y" ]; then
    start_spinner "Genererer Tailwind-konfiguration..."
    generate_tailwind_config "$DESIGN_TEMPLATE" "$PROJECT/tailwind.config.js"
    generate_tailwind_partial "$DESIGN_TEMPLATE" "$PROJECT/app/views/partials/tailwind.php"
    stop_spinner "Tailwind konfigureret"
  else
    cat > "$PROJECT/app/views/partials/tailwind.php" << 'PEOF'
<?php /* Tailwind er ikke aktiveret i dette projekt. Denne partial er en no-op
         så eksisterende includes ikke bryder. Tilføj dine egne <link>/<style>
         her hvis du senere vil introducere et CSS-framework. */ ?>
PEOF
  fi
}
