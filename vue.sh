# Get input from user
echo "Create a .NET project."
read -p "Project name: " name
read -p "Author name: " author
read -p "Deploy branch: " branch
echo "Creating Vue project: $name"
now=$(date +'%-m/%-d/%Y')

# Create Vue project in the user-given directory
mkdir ~/dev/Frontend
cd ~/dev/Frontend
vue create $name
cd $name

# Add npm packages
vue add router
vue add i18n
npm i node-sass@^6.0.1
npm i sass@^1.41.1
npm i sass-loader@^10.2.0
npm i axios

# Remove unused generated files
rm -R src/components/*
rm -R src/assets/*
rm -R src/views/*
rm -R src/router/*
rm src/App.vue

# Generate project directories
mkdir src/styles
mkdir src/assets/fonts
mkdir src/assets/images
mkdir src/services
mkdir .github
mkdir .github/workflows

# Generate template and static files
touch src/styles/_colors.scss
touch src/styles/_config.scss
touch src/styles/_dropdown.scss
touch src/styles/_fonts.scss
touch src/styles/_general.scss
touch src/styles/_types.scss

touch src/components/Button.vue
touch src/components/TextBox.vue

touch src/router/index.js
touch src/App.vue
touch src/views/Home.vue

# Write template code
echo ":root {
  --text: #000000;
  --background: #ffffff;
  --accent-1: #FFAC41;
  --accent-2: #FF1E56;
  --info: #aaaaaa;
  --cards: #efefef;
}

@media screen and (prefers-color-scheme: dark) {
  :root {
    --text: #ffffff;
    --background: #232323;
    --accent-1: #FFAC41;
    --accent-2: #FF1E56;
    --info: #aaaaaa;
    --cards: #454545;
  }
}

\$text: var(--text);
\$background: var(--background);
\$accent-1: var(--accent-1);
\$accent-2: var(--accent-2);
\$info: var(--info);
\$cards: var(--cards);

\$white: #ffffff;
\$black: #000000;

.success {
  color: #56bc46;
}" > src/styles/_colors.scss
echo "\$page-side-space: 20em;
\$page-top-space: 1em;
\$header-top-space: 2em;

\$title-size: 1.6em;
\$heading-size: 1.2em;
\$text-size: 1em;
\$desc-size: .9em;

\$transition: .12s;
\$radius: 0;
" > src/styles/_config.scss
echo "@use 'colors';

.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: colors.\$background;
  width: calc(30ch + 2em + 4px);
  box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, .2);
  z-index: 1;
  max-height: 70vh;
  overflow-y: scroll;
}

.dropdown:hover .dropdown-content {
  display: flex;
  flex-direction: column;
}

.dropdown-item {
  cursor: pointer;
  padding: .5em;
  padding-left: 1em;
  transition-duration: .12s;

  & * {
    cursor: pointer;
    user-select: none;
  }

  &:hover {
    background-color: colors.\$info;
  }
}

.dropdown-section-title {
  padding: 1em;
  font-size: .8em;
  font-weight: bold;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  background-color: colors.\$background;
}" > src/styles/_dropdown.scss
echo "@font-face {
  src: url('https://fonts.googleapis.com/css2?family=Poppins&display=swap');
  font-family: 'App';
}

@font-face {
  src: url('https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap');
  font-family: 'App';
  font-weight: bold;
}

.bold {
  font-weight: bold;
}" > src/styles/_fonts.scss
echo "@use '@/styles/config';
@use '@/styles/colors';

body {
  margin: 0;
  padding: 0;
  background-color: colors.\$background;
  overflow-x: hidden;
}

label {
  cursor: text;
  margin: 0;
}

a {
  &:hover {
    text-decoration: none;
  }
}

.page {
  padding-left: config.\$page-side-space;
  padding-right: config.\$page-side-space;
  padding-top: config.\$page-top-space;
  padding-bottom: config.\$page-top-space;
}

.page-header {
  display: flex;
  margin-bottom: config.\$header-top-space;

  & .page-header-title {
    width: fit-content;
    display: flex;
    align-items: center;
  }

  & .page-header-actions {
    width: fit-content;
    margin-right: 0;
    margin-left: auto;
    display: flex;
    gap: .5em;
  }
}" > src/styles/_general.scss
echo "@use '@/styles/config';
@use '@/styles/colors';

.title {
  font-family: 'App', sans-serif;
  font-size: config.\$title-size;
  font-weight: bold;
  color: colors.\$text;
}

.heading {
  font-family: 'App', sans-serif;
  font-size: config.\$heading-size;
  color: colors.\$text;
}

.info {
  font-family: 'App', sans-serif;
  font-size: config.\$desc-size;
  color: colors.\$info;
}

.content {
  font-family: 'App', sans-serif;
  font-size: config.\$text-size;
  color: colors.\$text;
}

.link {
  font-family: 'App', sans-serif;
  font-size: config.\$text-size;
  color: colors.\$accent-1;
  transition-duration: config.\$transition;
  text-decoration: none;
  cursor: pointer;

  &:hover {
    color: colors.\$accent-2;
  }
}" > src/styles/_types.scss
echo "import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
" > src/router/index.js
echo "<template>
  <router-view />
</template>

<script>
export default {
}
</script>

<style lang=\"scss\">
@use '@/styles/colors';
@use '@/styles/config';
@use '@/styles/dropdown';
@use '@/styles/fonts';
@use '@/styles/general';
@use '@/styles/types';
</style>
" > src/App.vue
echo "<template>
  <div class=\"page\">
  </div>
</template>

<script>
export default {
  name: 'Home'
}
</script>

<style lang=\"scss\">

</style>
" > src/views/Home.vue
echo "<template>
  <div v-bind:class=\"{ 'disabled': this.disabled, 'button-container': !this.disabled }\">
    <label class=\"content button-text\">{{ text }}</label>
  </div>
</template>

<script>
export default {
  props: {
    text: String,
    disabled: Boolean
  }
}
</script>

<style lang=\"scss\" scoped>
@use '@/styles/config';
@use '@/styles/colors';

.button-container {
  padding-top: .8em;
  padding-bottom: .8em;
  padding-left: 1.3em;
  padding-right: 1.3em;
  background-color: colors.\$accent;
  cursor: pointer;
  width: fit-content;
  border-radius: config.\$radius;
  transition-duration: config.\$transition;
  display: flex;
  align-items: center;

  &:hover {
    background-color: colors.\$accent-darker;
  }
}

.button-text {
  color: colors.\$white;
  user-select: none;
  cursor: pointer;
  font-size: config.\$text-size;
}

.disabled {
  padding-top: .8em;
  padding-bottom: .8em;
  padding-left: 1.3em;
  padding-right: 1.3em;
  background-color: colors.\$description;
  cursor: default;
  width: fit-content;
  border-radius: config.\$radius;
  display: flex;
  align-items: center;

  & .button-text {
    cursor: default;
  }
}
</style>
" > src/components/Button.vue
echo "<template>
  <div class=\"textbox\">
    <input type=\"text\"
           :placeholder=\"placeholder\"
           v-model=\"data\"
           v-on:change=\"output()\"
           required />
  </div>
</template>

<script>
export default {
  props: {
    placeholder: String,
    modelValue: String
  },
  data: function () {
    return {
      data: ''
    }
  },
  methods: {
    output: function () {
      this.\$emit('update:modelValue', this.data);
    }
  },
  watch: {
    modelValue: function () {
      this.data = this.modelValue
    }
  }
}
</script>

<style lang=\"scss\" scoped>
@use '@/styles/config';
@use '@/styles/colors';

\$box-border-width: 2px;

.textbox {
  width: 100%;
  border-radius: config.\$radius;

  & input {
    width: calc(100% - 2em - 2 * #{\$box-border-width});
    font-size: 1em;
    font-family: 'Poppins', sans-serif;
    
    padding-top: .6em;
    padding-bottom: .6em;
    padding-left: .8em;
    padding-right: .8em;
    outline: none;
    border: \$box-border-width solid colors.\$text-box;
    border-radius: config.\$radius;
    transition-duration: config.\$transition;
    background-color: colors.\$secondary;
    caret-color: colors.\$primary;
    color: colors.\$primary;

    &::placeholder {
      color: colors.\$text-box;
      opacity: 1;
      user-select: none;
    }

    &:focus {
      border: \$box-border-width solid colors.\$accent;
    }
  }
}
</style>
" > src/components/TextBox.vue

# Print info messages
echo "----- [ INFORMATION ] -----"
echo "Import your fonts to src/assets/fonts and add them to the src/assets/_fonts.scss file."
echo "You can adjust color configurations in the src/styles/_colors.scss file."
echo "To edit general configurations, change the variables in the src/styles/_config.scss file."

# Open in VSCode
code ../$name
