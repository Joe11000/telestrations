import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import DrawingSection from './DrawingSection'
import DescriptionSection from './DescriptionSection'
// import update from ImmutableHelper from 'immutability-helper'
// import update from ‘immutability-helper’


  // 'user drawing a picture' =
  // props = {
  //           'attention_users' => [user_2.id],
  //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
  //           'current_user_id' => user_2.id,
  //           'game_over' => false,
  //           'previous_card' => {
  //                                'medium' => 'description',
  //                                'description_text' => 'text_here'
  //                              },
  //           'user_status' => 'working_on_card'
  //         }


  // when 'user writing a description' and 'no previous card'  =
  // props = {
  //           'attention_users' => [current_user.id],
  //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
  //           'current_user_id' => current_user.id,
  //           'game_over' => false,
  //           'user_status' => 'working_on_card'
  //         }

  // when 'user writing a description' and 'yes, previous card'  =
    // props = {
    //           'attention_users' => [current_user.id],
    //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
    //           'current_user_id' => current_user.id,
    //           'game_over' => false,
    //           'user_status' => 'working_on_card',
    //           'previous_card' => {
    //              'medium' => 'drawing',
    //              'drawing_url' => drawing_url
    //            }
    //         }

  // 'after uploading a card a user has to wait for card to be passed to them', :r5 do
    // props = { 'attention_users' => [current_user.id],
    //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
    //           'current_user_id' => current_user.id,
    //           'game_over' => false,
    //           'user_status' => 'waiting'
    //         }

  // 'user has finished all uploads, but other players have not', :r5 do
    // props = { 'attention_users' => [current_user.id],
    //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
    //           'current_user_id' => current_user.id,
    //           'game_over' => false,
    //           'user_status' => 'finished'
    //         }


  // 'after the final player uploads the final card', :r5 do
    // props = { 'attention_users' => [user_1.id, user_2.id, user_3.id],
    //           'form_authenticity_token' => 'afheahshlfahflawhiulef',
    //           'current_user_id' => user_1.id,
    //           'game_over' => true,
    //           'url_redirect' => game_path(game.id)
    //         } # last player finishes


class Game extends React.Component {
  static propTypes() {

  }
  // componentWillReceiveProps(nextProps) {
  //   debugger
  //   if(nextProps.game_over == true) {
  //     debugger
  //     window.location = this.props.url_redirect
  //   }
  // }

  constructor(props) {
    super(props);
    this.state = {
      previous_card:            this.props.data.previous_card,
      user_status:              this.props.data.user_status,
      game_status:              this.props.data.game_status,
      current_user_id:          this.props.data.current_user_id,
      form_authenticity_token: this.props.data.form_authenticity_token
      // this.props.attention_users
      // this.props.game_over
    };
  }

  renderSection(status){
    switch(status) {
      case 'working_on_card':
        if(this.state.previous_card && this.state.previous_card.medium == 'drawing') {
          debugger
          return(<DrawingSection previous_card={this.state.previous_card}
                                 form_authenticity_token={this.props.data.form_authenticity_token}/>
                )
        }
        else{
          debugger
          return(<DescriptionSection back_up_starting_description={this.props.data.back_up_starting_description}
                                     form_authenticity_token={this.state.form_authenticity_token}
                                     previous_card={this.state.previous_card}/>
                )
        }
      case 'waiting':
      case 'finished':
        return(<LoadingContainer user_status={this.props.data.user_status}/>);
    }
  }
  render() {
    return (
      <div data-id='game-component'>
        <div className='form-horizontal'>
          <h1>Game Component</h1>

          <div className='col-12 offset-sm-1 col-sm-10 offset-md-2 col-md-8'>
            { this.renderSection(this.state.user_status) }
          </div>
        </div>
      </div>
    )
  }
}

Game.propTypes =  {
                    game_id:          PropTypes.oneOfType([ PropTypes.number, PropTypes.string ]),
                    previous_card_id: PropTypes.oneOfType([ PropTypes.number, PropTypes.string ]),
                    current_user_id:  PropTypes.oneOfType([ PropTypes.number, PropTypes.string ])
                  }


document.addEventListener('DOMContentLoaded', () => {
  const node = document.querySelector("[data-id='game-page-data']")
  const data = JSON.parse(node.getAttribute('data'))

  ReactDOM.render(
    <Game data={data}/>,
    document.querySelector("[data-id='game-page-data']")
  )
});






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
//               button.btn.btn-primary type='submit' Submit

//       p.h3#text-to-draw data-id='drawing-to-describe' = @text_to_draw

//     .loading-container.text-center. class=(@placeholder_card.blank? ? '' : 'd-none') data-id='loading-container'
//       p.h3 class=(@player_is_finished ? 'd-none' : '' ) data-id='set_not_complete' Waiting for a card to be passed to you.
//       p.h3 class=(@player_is_finished ? '' : 'd-none') data-id='set_complete' You are finished. Waiting for others to finish.
//       = image_tag 'loading_icon.gif', class: 'text-center mt-2', width:'80px'
