import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import SlideshowList from './SlideshowList'
import GameSelector from './GameSelector'

class Postgame extends React.Component {

  constructor(props) {
    super(props);
    debugger

    this.retrieveOutOfGameCards = this.retrieveOutOfGameCards.bind(this);

    this.state = {
      viewing_postgames: true
    }

    // this.postgame_tab = React.createRef();
    // this.out_of_game_card_upload_tab = React.createRef();
  }

  retrieveOutOfGameCards(event){
    event.preventDefault();

    if(this.state.viewing_postgames == false){
      this.setState({
        viewing_postgames: false
      });
    // axios card
    }
  }

  retrieveGameCards(event){
    event.preventDefault();

    this.setState({
      viewing_postgames: false
    });
    // axios card
  }

  render() {
    return (
      <div data-id='postgame-component'>
      <h1>Postgame Page</h1>
        <div className='card text-center'>
          <div className='card-header'>
            <div className='nav nav-tabs card-header-tabs'>
              <li className="nav-item">
                <a className='nav-link active' onClick={this.retrieveGameCards} href='#' ></a>
              </li>

              <li className="nav-item">
                <a className='nav-link' onClick={this.retrieveOutOfGameCards} href='#'></a>
              </li>
            </div>
          </div>

          <div className='card-body'>
            <GameSelector list_of_game_ids={[111,222,333,444,555,666]} />
            <SlideshowList decks='' />
          </div>
        </div>
        <div className='clearfix'>
        </div>
      </div>
    )
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const selector = "[data-id='postgame-page-data']"
  const node = document.querySelector(selector);
  const data = JSON.parse(node.getAttribute('data'));

    ReactDOM.render(
      <Postgame data={data}/>,
      document.querySelector(selector)
    )
});


    // - unless @out_of_game_card_upload.blank?
    //   h3.h3#out_of_game_card_upload-header.text-center = "Unassociated Cards I've uploaded"
    //   .out_of_game_card_upload-i-uploaded
    //     - carousel_id = "out_of_game_card_upload"
    //     .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
    //       /! Wrapper for slides
    //       .carousel-inner role="listbox"
    //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
    //           .item class=(card_container_index == 0 ? 'active' : '')
    //             = image_tag card_container.drawing.url, alt: 'User Drawing'

    //       /! Controls
    //       a.left.carousel-control data-slide='prev' href="##{carousel_id}" role='button'
    //         i.glyphicon.glyphicon-chevron-left.fa.fa-chevron-left aria-hidden='true'
    //         span.sr-only Previous
    //       a.right.carousel-control data-slide='next' href="##{carousel_id}" role='button'
    //         i.glyphicon.glyphicon-chevron-right.fa.fa-chevron-right aria-hidden='true'
    //         span.sr-only Next
    //       /! Indicators
    //       ol.carousel-indicators
    //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
    //           li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
    //     hr


    // .col-12.col-sm-12.text-center
    //   - if @arr_of_postgame_card_sets.blank?
    //     h3.h3 No Games Have Been Played

    //   - else
    //     h3.h3.text-center All Games I've played
    //     h6.h6.text-center.glow = "( Colored 'Created By' cards were made by you. )"
    //     = render partial: 'shared/card_slideshow', locals: { arr_of_postgame_card_sets: @arr_of_postgame_card_sets}
{/*}*/}




// shared/card_slideshow.html.slim
// / locals : { arr_of_postgame_card_sets: [ @game1.cards_from_finished_game (, ...)]  }
//   / arr_of_postgame_card_sets :  [   [  [   [       [     ,      ] ], [  ] ] ]   ]
//   /                              g  gu  c   g_u_n   card     c

//   / The card.uploader_id compared to @current_user.id will reveal if current_user drew that card
//   / have text glow if
// .carousel-wrapper
//   - arr_of_postgame_card_sets.each_with_index do |game_card_set, game_card_set_index|
//     hr
//     h3.h3.game-index-counter = "Game #{game_card_set_index + 1}"
//     - game_card_set.each_with_index do |games_user, games_user_index|
//       - unless games_user_index == 0
//         hr.dotted-line

//       - carousel_id = "carousel-#{games_user_index}"
//       .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
//         /! Indicators
//         ol.carousel-indicators
//           - games_user.each_with_index do |card_container, card_container_index|
//             li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
//         /! Wrapper for slides
//         .carousel-inner
//           - games_user.each_with_index do |card_container, card_container_index|
//             .carousel-item.text-center class=(card_container_index == 0 ? 'active' : '')
//               - if(card_container[1].drawing?)

//                 img.d-block.text-center src=get_drawing_url(card_container[1]) alt='Drawing to Describe' style='max-width: 325px; max-height: 375px; margin: auto;'
//                 / = image_tag get_drawing_url(card_container[1]), alt: "Drawing to describe", class: 'd-block'
//               - elsif(card_container[1].description?)
//                 h4.h4.description-text.text-center = card_container[1].description_text

//               .carousel-caption.d-block
//                 - did_i_make_card = card_container[1].uploader_id == @current_user.id
//                 p.h4 class=(did_i_make_card ? 'glow': '') Created By:
//                 p.h5 class=(did_i_make_card ? 'glow': '') = card_container[0]



//         /! Controls
//         a.carousel-control-prev data-slide='prev' href="##{carousel_id}" role='button'
//           span.carousel-control-prev-icon aria-hidden="true"
//           span.sr-only Previous

//         a.carousel-control-next data-slide='next' href="##{carousel_id}" role='button'
//           span.carousel-control-next-icon aria-hidden="true"
//           span.sr-only Previous
