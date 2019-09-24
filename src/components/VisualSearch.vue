<template>
  <div class="hello">
    <br />
    <br />
    <picture-input
        ref="pictureInput"
        margin="16"
        width="600"
        height="600"
        accept="image/jpeg,image/jpg"
        capture="user"
        size="10"
        button-class="btn"
        zIndex=0
        :custom-strings="{
          drag: 'Drag an image'
        }"
        @change="onChange">
    </picture-input>
    <br />
    <br />
    <div v-if="seen">
        <v-row>
          <v-col cols="12" sm="6" offset-sm="3">
            <v-card>
              <v-container fluid>
                <v-row align="center" justify="center">
                  <v-col
                      v-for="image in images"
                      class="d-flex child-flex"
                      cols="2"
                      align="center" justify="center"
                  >
                    <v-card flat tile class="d-flex">
                      <v-img
                          :src="`https://storage.cloud.google.com/lbc_images/images/${image.id}.jpg`"
                          :lazy-src="`https://http.cat/404?p=9629`"
                          aspect-ratio="1"
                          @click="onclickimage(`https://storage.cloud.google.com/lbc_images/images/${image.id}.jpg`)"
                          class="grey lighten-2"
                      >
                        <template v-slot:placeholder>
                          <v-row
                              class="fill-height ma-0"
                              align="center"
                              justify="center"
                          >
                            <v-progress-circular indeterminate color="grey lighten-5"></v-progress-circular>
                          </v-row>
                        </template>
                      </v-img>
                    </v-card>
                  </v-col>
                  <v-overlay
                      :value="overlay"
                      :z-index=10000
                  >
                    <v-img
                        :src="zoomimage"
                        @click="overlay = false"
                    ></v-img>
                  </v-overlay>
                </v-row>
              </v-container>
            </v-card>
          </v-col>
        </v-row>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import PictureInput from 'vue-picture-input'

  export default {
    name: 'visualsearch',
    data () {
      return {
        seen: false,
        overlay: false,
        images: null,
        zoomimage: null
      }
    },
    components: {
      PictureInput
    },
    methods: {
      onclickimage(image) {
        this.exists(image, this.zoom)
      },
      exists(image, callback) {
        var img = new Image()
        img.onload = function () {
          callback(image)
        }
        img.src = image
      },
      zoom(image) {
        this.zoomimage = image
        this.overlay = true
      },
      loadImage (image, callback) {
        var img = new Image()
        img.onload = function () {
          var canvas = document.createElement('canvas')
          var ctx = canvas.getContext('2d')
          canvas.width = 224
          canvas.height = 224
          // Resize
          ctx.drawImage(this, 0, 0, 224, 224)
          callback(canvas)
        }
        img.src = image
      },
      computeSimilarity (img) {
        img.toBlob((blob) => {
          let data = new FormData();
          data.append('picture', blob, "image.jpg");

          axios.post(`http://localhost:8080/api/v1/similar`, data, {
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          })
          .then(res => {
            this.images = res.data
          }, error => {
            console.error(error)
          });
        }, 'image/jpeg', 1.0)
      },
      onChange (image) {
        if (image) {
          this.loadImage(image, this.computeSimilarity)
          this.seen = true
        } else {
          console.log('FileReader API not supported: use the <form> !')
        }
      }
    }
  }
</script>
