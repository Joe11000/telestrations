import React from 'react'
import PropTypes from 'prop-types'

// props = { previous_card: {medium: 'description', descripion_text: 'https://somewhere.com/stuff/jpg' }
//           form_authenticity_token: 'fashlashleasf-32fsdfag4srfds'
//         }
export default class DrawingSection extends React.Component {
  constructor(props) {
    super(props);

    this.submit_button = React.createRef();
  }

  disableButton(event){
    this.submit_button.current.disabled = true
  }

  render() {
    return (


      <div className='make-drawing-container'>
        <div className='card'>
          <div className='card-body'>
          <h5 className="card-title text-dark">Upload Drawing of the description</h5>

            <form className="make-drawing-form mt-2"
                  action='/cards/in_game_card_uploads'
                  method='post'
                  data-remote='true'
                  enctype="multipart/form-data"
                  accept-charset="UTF-8"
                  onSubmit={(e) => this.disableButton(e)}
                  data-id="make-drawing-form"
                  id='make-drawing-form'>
              <input type="hidden" name="authenticity_token" value={this.props.authenticity_token} />
              {/*<input name="utf8" type="hidden" value="✓">*/}

              <div className='form-group'>
                <label htmlFor='card-drawing' className='text-primary'>{this.props.previous_card.description_text}</label>
                <input type="file" name="card[drawing]"
                       className="form-control-file border-transparent"
                       title="Can't be blank"
                       id='card-drawing'
                       accept="image/png,image/gif,image/jpeg,image/jpg"/>
              </div>
              <br className='d-inline-block'/>

              <button className="btn btn-primary d-inline-block" ref={this.submit_button} type="submit">Submit Text</button>
            </form>
          </div>

        </div>
      </div>




/*        <div data-id="make-drawing-container" id="make-drawing-container">
          <div class="mb-3" id="description-to-draw">
            <p class="h3 capitalize text-center" data-id="description-text-to-draw" id="text-to-draw">
              description_text
            </p>
            </div>
            <div data-id="drawing-tab" id="drawing-tab">
              <ul class="nav nav-tabs nav-justified" role="tablist">
                <li class="active" role="presentation">
                  <a data-toggle="tab" href="#upload-drawing">Upload</a>
                </li>
                <li role="presentation">
                  <a href="#create-drawing">Create</a>
                </li>
              </ul>
            </div>
          </div>*/

/*
     #make-drawing-container data-id='make-drawing-container' class=(@placeholder_card.try(:is_drawing?) ? '' : 'd-none')
          #description-to-draw.mb-3
            p#text-to-draw.h3.capitalize.text-center data-id='description-text-to-draw' = @prev_card.blank? ? '' : @prev_card.try(:description_text)
          #drawing-tab data-id='drawing-tab'
            ul.nav.nav-tabs.nav-justified role='tablist'
              li.active role="presentation"
                a href="#upload-drawing"  data-toggle='tab' Upload
              li role="presentation"
                a href="#create-drawing" Create


            .tab-content
              #create-drawing.tab-pane.fade.in.active role="tabpanel"
                div
                 span drawing here
              #upload-drawing.tab-pane.fade.pt-5 role="tabpanel"
                #file_upload

                / bootstrap instructions on how to fix tab
                / <ul class="nav nav-tabs" id="myTab" role="tablist">
                /   <li class="nav-item">
                /     <a class="nav-link active" id="home-tab" data-toggle="tab" href="#home" role="tab" aria-controls="home" aria-selected="true">Home</a>
                /   </li>
                /   <li class="nav-item">
                /     <a class="nav-link" id="profile-tab" data-toggle="tab" href="#profile" role="tab" aria-controls="profile" aria-selected="false">Profile</a>
                /   </li>
                /   <li class="nav-item">
                /     <a class="nav-link" id="contact-tab" data-toggle="tab" href="#contact" role="tab" aria-controls="contact" aria-selected="false">Contact</a>
                /   </li>
                / </ul>
                / <div class="tab-content" id="myTabContent">
                /   <div class="tab-pane fade show active" id="home" role="tabpanel" aria-labelledby="home-tab">...</div>
                /   <div class="tab-pane fade" id="profile" role="tabpanel" aria-labelledby="profile-tab">...</div>
                /   <div class="tab-pane fade" id="contact" role="tabpanel" aria-labelledby="contact-tab">...</div>
                / </div>
*/
      // </div>
    )
  }
}






// Original Version before seperating


// #game data-id='game-page' data-game-id=@game.id data-prev-card-id=(@prev_card.try(:id) || '') data-user-id=(@current_user.try(:id) || "")
//   .form-horizontal
//     .drawing.col-12.offset-sm-1.col-sm-10.offset-md-2.col-md-8
//       #make-drawing-container data-id='make-drawing-container' class=(@placeholder_card.try(:is_drawing?) ? '' : 'd-none')
//         #description-to-draw.mb-3
//           p#text-to-draw.h3.capitalize.text-center data-id='description-text-to-draw' = @prev_card.blank? ? '' : @prev_card.try(:description_text)
//         #drawing-tab data-id='drawing-tab'
//           ul.nav.nav-tabs.nav-justified role='tablist'
//             li.active role="presentation"
//               a href="#upload-drawing"  data-toggle='tab' Upload
//             li role="presentation"
//               a href="#create-drawing" Create


//           .tab-content
//             #create-drawing.tab-pane.fade.in.active role="tabpanel"
//               div
//                span drawing here
//             #upload-drawing.tab-pane.fade.pt-5 role="tabpanel"
//               #file_upload

//               / bootstrap instructions on how to fix tab
//               / <ul class="nav nav-tabs" id="myTab" role="tablist">
//               /   <li class="nav-item">
//               /     <a class="nav-link active" id="home-tab" data-toggle="tab" href="#home" role="tab" aria-controls="home" aria-selected="true">Home</a>
//               /   </li>
//               /   <li class="nav-item">
//               /     <a class="nav-link" id="profile-tab" data-toggle="tab" href="#profile" role="tab" aria-controls="profile" aria-selected="false">Profile</a>
//               /   </li>
//               /   <li class="nav-item">
//               /     <a class="nav-link" id="contact-tab" data-toggle="tab" href="#contact" role="tab" aria-controls="contact" aria-selected="false">Contact</a>
//               /   </li>
//               / </ul>
//               / <div class="tab-content" id="myTabContent">
//               /   <div class="tab-pane fade show active" id="home" role="tabpanel" aria-labelledby="home-tab">...</div>
//               /   <div class="tab-pane fade" id="profile" role="tabpanel" aria-labelledby="profile-tab">...</div>
//               /   <div class="tab-pane fade" id="contact" role="tabpanel" aria-labelledby="contact-tab">...</div>
//               / </div>



//     #make-description-container data-id='make-description-container' class=(@placeholder_card.try(:description?) ? '' : 'd-none')
//       #drawing-to-describe-container.mt-2.text-center data-id='drawing-to-describe-container'
//         img#drawing-to-describe data-id='drawing-to-describe' src=( @prev_card.blank? ? '' : @prev_card.try(:drawing).try(:url) )

//       form.make-description-form.mt-2 data-id='make-description-form'
//         .form-group data-id='make-description-group'
//           .input-group
//             = text_field_tag(:description_text_input_field, nil,  {data: {id: 'description_text_input_field'}, placeholder: 'Enter A Description', class: 'span2 form-control text-capitalize'})
//             .input-group-btn
//               button.btn.btn-primary type='Submit Text' Submit

//       p.h3#text-to-draw data-id='drawing-to-describe' = @text_to_draw

//     .loading-container.text-center. class=(@placeholder_card.blank? ? '' : 'd-none') data-id='loading-container'
//       p.h3 class=(@player_is_finished ? 'd-none' : '' ) data-id='set_not_complete' Waiting for a card to be passed to you.
//       p.h3 class=(@player_is_finished ? '' : 'd-none') data-id='set_complete' You are finished. Waiting for others to finish.
//       = image_tag 'loading_icon.gif', class: 'text-center mt-2', width:'80px'
