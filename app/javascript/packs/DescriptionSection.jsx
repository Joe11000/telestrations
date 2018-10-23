import React from 'react'
import PropTypes from 'prop-types'

// props = { previous_card:  { medium: 'drawing', drawing_url: 'https://somewhere.com/something.jpg' } }
// XOR
// props = { previous_card: undefined }
export default class DescriptionSection extends React.Component {
  render() {
    return (
      <div className='make-description-container'>
        <p>Make Description Container</p>

{/*      <div id='make-description-container' data-id='make-description-container' className={(this.props.medium == 'description') ? '' : 'd-none'}>
        <div id='drawing-to-describe-container' data-id='drawing-to-describe-container' className='mt-2 text-center'>
          <img id='drawing-to-describe'  data-id='drawing-to-describe' src=( @prev_card.blank? ? '' : @prev_card.try(:drawing).try(:url)>
        </div>
      </div>*/}

      <div className='card'>
        <img data-id="describe-the-drawing"
             id="drawing-to-describe"
             src={this.props.previous_card && this.props.previous_card.drawing_url}
             className='card-img-top'
             alt='Describe the drawing'
             />
        <div className='card-body'>
          <h5 class="card-title">Describe The Drawing</h5>
          <form className="make-description-form mt-2" data-id="make-description-form">
            <input type="text" name="description_text_input_field"
                   id="description_text_input_field"
                   data-id="description_text_input_field"
                   placeholder="Enter A Description" className="span2 card-text text-capitalize" />

            <button className="btn btn-primary" type="submit">Submit</button>
          </form>
        </div>



      {/*original html*/}
{/*      <div data-id="make-description-container" id="make-description-container" className='card text-center'>
        <div className="mt-2 text-center" data-id="drawing-to-describe-container" id="drawing-to-describe-container">
          <img data-id="drawing-to-describe" id="drawing-to-describe" src={this.props.previous_card && this.props.previous_card.drawing_url}>
        </div>
        <form className="make-description-form mt-2" data-id="make-description-form">
          <div className="form-group" data-id="make-description-group">
            <div className="input-group">
              <input type="text" name="description_text_input_field"
                                 id="description_text_input_field"
                                 data-id="description_text_input_field"
                                 placeholder="Enter A Description" className="span2 form-control text-capitalize">
              <div className="input-group-btn">
                <button className="btn btn-primary" type="submit">Submit</button>
              </div>
            </div>
          </div>
        </form>*/}
        {/*<p className="h3" data-id="drawing-to-describe" id="text-to-draw">text_to_draw</p>*/}
      </div>


{/*       #make-description-container data-id='make-description-container' class=(@placeholder_card.try(:description?) ? '' : 'd-none')
         #drawing-to-describe-container.mt-2.text-center data-id='drawing-to-describe-container'
           img#drawing-to-describe data-id='drawing-to-describe' src=( @prev_card.blank? ? '' : @prev_card.try(:drawing).try(:url) )

         form.make-description-form.mt-2 data-id='make-description-form'
           .form-group data-id='make-description-group'
             .input-group
               = text_field_tag(:description_text_input_field, nil,  {data: {id: 'description_text_input_field'}, placeholder: 'Enter A Description', class: 'span2 form-control text-capitalize'})
               .input-group-btn
                 button.btn.btn-primary type='submit' Submit

         p.h3#text-to-draw data-id='drawing-to-describe' = @text_to_draw*/}
      </div>

    )
  }
}









// Original HTML version before seperating
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



















// Original JS version before seperating
// (function(){
//   if ($("[data-id='game-page']").length > 0){

//     $("[data-id='make-description-form']").submit( function(e){

//       $(this).find('button').prop('disabled', true); // prevent user from submitting multiple times
//       var description_text = $(this).find('input').val();
//       hideAndClearCardContainers();
//       App.game.upload_card({description_text: description_text});
//       return false;
//     });

//     showLoadingContainer = function(status) {
//       if(status === 'set_complete')
//       {
//         $("[data-id='set_complete']").removeClass('d-none');
//         $("[data-id='set_not_complete']").addClass('d-none');
//       }

//       $("[data-id='loading-container']").removeClass('d-none');
//     }

//     hideLoadingContainer = function(status) {
//       $("[data-id='loading-container']").addClass('d-none');
//     }

//     hideAndClearCardContainers = function(){
//       // hide drawing container if it is visible
//         var $element = $("[data-id='make-drawing-container']:visible");


//       if ($element.length > 0 )
//       {
//       // disable the button in the photo upload form
//         $('[data-id=submitPhoto]').prop('disabled', false);

//         // hide the description input container
//           $("[data-id='make-drawing-container']").addClass('d-none');
//         // todo : clear the paint portion!!!
//       }

//       // hide description container if it is visible
//       var $element = $("[data-id='make-description-container']:visible")
//       if ($element.length > 0 )
//       {
//         // hide the description input container
//           $("[data-id='make-description-container']").addClass('d-none');

//         // clear description input field
//           $("[data-id='make-description-container'] form")[0].reset();
//       }
//       showLoadingContainer();
//     }

//     // prev_card_info: { id: card_id, description_text: description_text }
//     window.updatePageForNextDrawingCard = function(prev_card_info) {
//       hideLoadingContainer();

//       // change description text to draw
//         $("[data-id='description-text-to-draw']").html(prev_card_info['description_text']);

//       // show the drawing area
//         $("[data-id='make-drawing-container']").removeClass('d-none');

//       // replace prev card info at the top of the screen
//         $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id']);
//     };

//     // prev_card_info: { id: card_id, drawing_url: url }
//     window.updatePageForNextDescriptionCard = function(prev_card_info) {
//       hideLoadingContainer();

//       // change the url of the image to describe
//         $("[data-id='drawing-to-describe']").attr('src', prev_card_info['drawing_url'])

//       // enable user to submit description
//         $("[data-id='make-description-form'] button").prop('disabled', false);

//       // show the description area
//         $("[data-id='make-description-container']").removeClass('d-none')

//       // replace prev card info at the top of the screen
//         $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id'])
//     }

//     $("#drawing-tab a").click(function (e) {
//       e.preventDefault();
//       $(this).tab('show');
//     });

//     // file upload via game socket
//     // var files = [];
//     // $("[data-class='file_upload_form'] input[type=file]").change(function(event) {
//     //   $.each(event.target.files, function(index, file) {
//     //     var reader = new FileReader();
//     //     reader.onload = function(event) {
//     //       object = {};
//     //       object.filename = file.name;
//     //       object.data = event.target.result;
//     //       files.push(object);
//     //     };
//     //     reader.readAsDataURL(file);
//     //   });

//     //   if (event.target.files.length > 0) {
//     //     $('[data-id=submitPhoto]').prop('disabled', false);
//     //   }
//     //   else {
//     //     $('[data-id=submitPhoto]').prop('disabled', true);
//     //   }
//     // });

//     // $("[data-class='file_upload_form']").submit(function(event) {
//     //   event.preventDefault();
//     //   showLoadingContainer();
//     //   hideAndClearCardContainers();

//     //   $.each(files, function(index, file) {
//     //     var image_info = {filename: file.filename, data: file.data};
//     //     App.game.upload_card(image_info);
//     //   });

//     //   //  reset form and ready for next time
//     //   files = [];
//     //   $("[data-class='file_upload_form'] input[type=file]").val('');
//     // });
//   }
// })();
