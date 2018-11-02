import React from 'react'
import PropTypes from 'prop-types'

// props = { previous_card:  { medium: 'drawing', drawing_url: 'https://somewhere.com/something.jpg' } }
// XOR
// props = { previous_card: undefined }
export default class DescriptionSection extends React.Component {
  constructor(props){
    super(props)
    this.random_description_text = React.createRef();
    this.custom_description_text = React.createRef();
  }

  disableButtons(event){
    this.random_description_text.current.disabled =  true
    this.custom_description_text.current.disabled =  true
  }

  render() {
    var topText = '';
    var topImage = '';

    if(this.props.previous_card && this.props.previous_card.drawing_url) {
      topText = <h5 className="card-title text-dark">Describe The drawing</h5>
    }
    else{
      topText = <h5 className="card-title text-dark">Think up an idea for the next person to draw</h5>
    }

    var back_up_starting_description_form_button = '';
    if( !(this.props.previous_card && this.props.previous_card.drawing_url) ) {
      back_up_starting_description_form_button = <form action='/cards/in_game_card_uploads' method='post' data-remote='true' onSubmit={(e) => this.disableButtons(e)} className='d-inline-block' >
                                                  <input type="hidden" name="authenticity_token" value={this.props.authenticity_token} />
                                                  <input type="hidden" name="card[description_text]" id="hidden_description_text_input_field" data-id="hidden_description_text_input_field" value={this.props.back_up_starting_description} />
                                                  <button ref={this.custom_description_text} className='btn btn-info ml-3' type='submit'>Submit Random Answer</button>
                                                </form>
    }
    else {
      topImage =  <img src={this.props.previous_card && this.props.previous_card.drawing_url}
                       className='card-img-top'
                       alt='Describe the drawing'
                  />
    }

    return (
      <div className='make-description-container'>
        <div className='card'>
          {topImage}
          <div className='card-body'>
            {topText}

            <form className="make-description-form mt-2" action='/cards/in_game_card_uploads' method='post' data-remote='true' onSubmit={(e) => this.disableButtons(e)} data-id="make-description-form" id='make-description-form'>
              <input type="hidden" name="authenticity_token" value={this.props.authenticity_token} />

              <input type="text" name="card[description_text]"
                     className="span2 card-text text-capitalize form-control" title="Can't be blank" />

              <br className='d-inline-block'/>
            </form>
              <button className="btn btn-primary d-inline-block" form='make-description-form' ref={this.random_description_text} type="submit">Submit Text</button>
              {back_up_starting_description_form_button}
          </div>

        </div>
      </div>
    )
  }
}





// - static getDerivedStateFromProps()
// render()
// componentDidMount()


//  - static getDerivedStateFromProps()
//  - shouldComponentUpdate()
// render()
//  - getSnapshotBeforeUpdate()
// componentDidUpdate()


// Other APIs
// Each component also provides some other APIs:
//   setState()
//   forceUpdate()







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
