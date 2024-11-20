#!/usr/bin/env bash

gen_top(){
  cat <<EOF > README.md
![Personal Website](https://raw.githubusercontent.com/Apollorion/apollorion/main/logos/new-large-white-transparent.png#gh-dark-mode-only)![Personal Website](https://raw.githubusercontent.com/Apollorion/apollorion/main/logos/new-large-black-transparent.png#gh-light-mode-only)

<p align="center">
    <b>Hello, I'm Joey 👋</b>
</p>

EOF
}

gen_blusky_posts(){

  echo "## Latest BlueSky Posts" >> README.md

  # Query bluesky for posts
  export MAX_POSTS=5
  posts=$(curl -sS -H "Accept: application/json" "https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=apollorion.com&limit=$MAX_POSTS")

  length=$(echo "$posts" | jq ".feed | length")

  # Parse the posts
  for i in $(seq 0 $((length - 1))); do
      text=$(echo "$posts" | jq -r ".feed[$i].post.record.text")
      uri=$(echo "$posts" | jq -r ".feed[$i].post.uri" | awk -F'/' '{print $NF}')

      date=$(echo "$posts" | jq -r ".feed[$i].post.record.createdAt")
      date=${date%%T*}

      echo "$date: [$text](https://bsky.app/profile/apollorion.com/post/$uri)  " >> README.md
  done

  echo "" >> README.md
}

gen_opentofu_resource(){

  links=$(curl -sS https://raw.githubusercontent.com/Apollorion/profile/refs/heads/main/_data/links.yml)

  cat <<EOF >> README.md
\`\`\`hcl
resource "github_introduction" "joey" {
    name      = "Joey Stout"
    interests = ["kubernetes", "opentofu", "nodejs", "python", "gitops"]
    resume    = "https://apollorion.com/joeysResume.pdf"

EOF

  length_of_categories=$(echo "$links" | yq '.buttons | length')

  for i in $(seq 0 $((length_of_categories - 1))); do
    category=$(echo "$links" | yq -r ".buttons[$i].category" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    length_of_items=$(echo "$links" | yq ".buttons[$i].items | length")

    echo "    $category = [" >> README.md

    for j in $(seq 0 $((length_of_items - 1))); do
      url=$(echo "$links" | yq -r ".buttons[$i].items[$j].url")
      echo "        \"$url\"," >> README.md
    done

    echo "    ]" >> README.md
    if [ $i -ne $((length_of_categories - 1)) ]; then
      echo "" >> README.md
    fi
  done

cat <<EOF >> README.md
}
\`\`\`

EOF
}

gen_bottom(){
  cat <<EOF >> README.md

<p align="center">
    <a href="https://www.buymeacoffee.com/apollorion"><sub><sub>Buy Me A Coffee</sub></sub></a> <sub><sub>|</sub></sub> <a href="https://apollorion.com/joeysResume.pdf"><sub><sub>Resume</sub></sub></a>
</p>
EOF
}

# Actually call the functions and generate the readme
gen_top
gen_opentofu_resource
gen_blusky_posts
gen_bottom