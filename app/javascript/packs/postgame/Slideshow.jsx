import React, { Component } from 'react';
import {
  Carousel,
  CarouselItem,
  CarouselControl,
  CarouselIndicators,
  CarouselCaption
} from 'reactstrap';

// let items = [
//   {
//     src: 'data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%22800%22%20height%3D%22400%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20800%20400%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder_15ba800aa1d%20text%20%7B%20fill%3A%23555%3Bfont-weight%3Anormal%3Bfont-family%3AHelvetica%2C%20monospace%3Bfont-size%3A40pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder_15ba800aa1d%22%3E%3Crect%20width%3D%22800%22%20height%3D%22400%22%20fill%3D%22%23777%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%22285.921875%22%20y%3D%22218.3%22%3EFirst%20slide%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E',
//     altText: 'Slide 1',
//     caption: 'Slide 1'
//   },
//   {
//     src: 'data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%22800%22%20height%3D%22400%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20800%20400%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder_15ba800aa20%20text%20%7B%20fill%3A%23444%3Bfont-weight%3Anormal%3Bfont-family%3AHelvetica%2C%20monospace%3Bfont-size%3A40pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder_15ba800aa20%22%3E%3Crect%20width%3D%22800%22%20height%3D%22400%22%20fill%3D%22%23666%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%22247.3203125%22%20y%3D%22218.3%22%3ESecond%20slide%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E',
//     altText: 'Slide 2',
//     caption: 'Slide 2'
//   },
//   {
//     src: 'data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%22800%22%20height%3D%22400%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20800%20400%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder_15ba800aa21%20text%20%7B%20fill%3A%23333%3Bfont-weight%3Anormal%3Bfont-family%3AHelvetica%2C%20monospace%3Bfont-size%3A40pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder_15ba800aa21%22%3E%3Crect%20width%3D%22800%22%20height%3D%22400%22%20fill%3D%22%23555%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%22277%22%20y%3D%22218.3%22%3EThird%20slide%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E',
//     altText: 'Slide 3',
//     caption: 'Slide 3'
//   }
// ];

class Slideshow extends Component {
  constructor(props) {
    super(props);

    this.next = this.next.bind(this);
    this.previous = this.previous.bind(this);
    this.goToIndex = this.goToIndex.bind(this);
    this.onExiting = this.onExiting.bind(this);
    this.onExited = this.onExited.bind(this);
    this.acquireCardInfoForCarousel = this.acquireCardInfoForCarousel.bind(this);

    const _carousel_card_info = this.acquireCardInfoForCarousel(this.props.deck)

    this.state = {
                   activeIndex: 0,
                   carousel_card_info: _carousel_card_info,
                 };
  }

  acquireCardInfoForCarousel(deck) {
    return deck.map((card_info, index) => {
      if(card_info[1].medium === 'description'){
        return({
                src: '',
                altText: card_info[1].description_text,
                caption: `By: ${card_info[0]}`
              })
      }
      else if (card_info[1].medium === 'drawing') {
      return({
                src: card_info[1].drawing_url,
                altText: '',
                caption: `By: ${card_info[0]}`
            })
      }
      else {
        throw new Error('Card must be a drawing or a description');
      }
    })
  }

  onExiting() {
    this.animating = true;
  }

  onExited() {
    this.animating = false;
  }

  next() {
    if (this.animating) return;
    const nextIndex = this.state.activeIndex === items.length - 1 ? 0 : this.state.activeIndex + 1;
    this.setState({ activeIndex: nextIndex });
  }

  previous() {
    if (this.animating) return;
    const nextIndex = this.state.activeIndex === 0 ? items.length - 1 : this.state.activeIndex - 1;
    this.setState({ activeIndex: nextIndex });
  }

  goToIndex(newIndex) {
    if (this.animating) return;
    this.setState({ activeIndex: newIndex });
  }

  render() {
    const { activeIndex } = this.state;

    let items = this.state.carousel_card_info

    const slides = items.map((items) => {
      return (
        <CarouselItem
          onExiting={this.onExiting}
          onExited={this.onExited}
          key={items.src}
          >
          <img className="d-block w-100" src={item.src} alt={item.altText} />
          
          <CarouselCaption captionText={items.caption} captionHeader={items.caption} />
        </CarouselItem>
      );
    });

    return (
      <Carousel
        activeIndex={activeIndex}
        next={this.next}
        previous={this.previous}
      >
        <CarouselIndicators items={items} activeIndex={activeIndex} onClickHandler={this.goToIndex} />
        {slides}
        <CarouselControl direction="prev" directionText="Previous" onClickHandler={this.previous} />
        <CarouselControl direction="next" directionText="Next" onClickHandler={this.next} />
      </Carousel>
    );
  }
}

export default Slideshow;


















// import React from 'react'
// import PropTypes from 'prop-types'
// // import LoadingIcon from 'images/loading_icon.gif'
// import {
//   Carousel,
//   CarouselItem,
//   CarouselControl,
//   CarouselIndicators,
//   CarouselCaption
// } from 'reactstrap';

// let items = []

// class Slideshow extends React.Component {
//   constructor(props) {
//     super(props);


//     const _items = this.acquireCardInfoForCarousel(this.props.deck)
//     debugger
//     this.items = this.acquireCardInfoForCarousel(this.props.deck)

//     this.state = { activeIndex: 0, items:  _items };

//     this.next = this.next.bind(this);
//     this.previous = this.previous.bind(this);
//     this.goToIndex = this.goToIndex.bind(this);
//     this.onExiting = this.onExiting.bind(this);
//     this.onExited = this.onExited.bind(this);
//     this.acquireCardInfoForCarousel = this.acquireCardInfoForCarousel.bind(this);

//   }

//   acquireCardInfoForCarousel(deck) {
//     return deck.map((card_info, index) => {
//       if(card_info[1].medium === 'description'){
//         return({
//                 src: '',
//                 altText: card_info[1].description_text,
//                 caption: `By: ${card_info[0]}`
//               })
//       }
//       else if (card_info[1].medium === 'drawing') {
//       return({
//                 src: card_info[1].drawing_url,
//                 altText: '',
//                 caption: `By: ${card_info[0]}`
//             })
//       }
//       else{
//       throw new Error('Card must be a drawing or a description');
//       }
//     })
//   }

//   onExiting() {
//     this.animating = true;
//   }

//   onExited() {
//     this.animating = false;
//   }

//   next() {
//     if (this.animating) return;
//     const nextIndex = this.state.activeIndex === this._items.length - 1 ? 0 : this.state.activeIndex + 1;
//     this.setState({ activeIndex: nextIndex });
//   }

//   previous() {
//     if (this.animating) return;
//     const nextIndex = this.state.activeIndex === 0 ? this._items.length - 1 : this.state.activeIndex - 1;
//     this.setState({ activeIndex: nextIndex });
//   }

//   goToIndex(newIndex) {
//     if (this.animating) return;
//     this.setState({ activeIndex: newIndex });
//   }

//   render() {
//     const { activeIndex } = this.state;
//     const that_props = this.props

//     const slides = items.map((item) => {
//       return (
//         <CarouselItem
//           onExiting={this.onExiting}
//           onExited={this.onExited}
//           key={item.src}
//         >
//           <img src={item.src} alt={item.altText} />
//           <CarouselCaption captionText={item.caption} captionHeader={item.caption} />
//         </CarouselItem>
//       );
//     });

//     return (
//       <Carousel
//         activeIndex={activeIndex}
//         next={this.next}
//         previous={this.previous}
//       >
//         <CarouselIndicators _items={this._items} activeIndex={activeIndex} onClickHandler={this.goToIndex} />
//         {slides}
//         <CarouselControl direction="prev" directionText="Previous" onClickHandler={this.previous} />
//         <CarouselControl direction="next" directionText="Next" onClickHandler={this.next} />
//       </Carousel>
//     );
//   }


// // render() {
// //   debugger
// //   // const that_props = this.props;
// //   that_key_preface = this.props.key_preface;
// //   return (
// //     <div className='carousel'>
// //     {
// //       this.props.deck.forEach((element, index) => {
// //         return(
// //           <div className='item' key={`${that_key_preface}-${index}`}>
// //             {`${that_key_preface}-${index}`}
// //           </div>
// //         )
// //       })
// //     }
// //     </div>
// //   )
// // }
// }

// export default Slideshow;












//     //     .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
//     //       /! Wrapper for slides
//     //       .carousel-inner role="listbox"
//     //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
//     //           .item class=(card_container_index == 0 ? 'active' : '')
//     //             = image_tag card_container.drawing.url, alt: 'User Drawing'

//     //       /! Controls
//     //       a.left.carousel-control data-slide='prev' href="##{carousel_id}" role='button'
//     //         i.glyphicon.glyphicon-chevron-left.fa.fa-chevron-left aria-hidden='true'
//     //         span.sr-only Previous
//     //       a.right.carousel-control data-slide='next' href="##{carousel_id}" role='button'
//     //         i.glyphicon.glyphicon-chevron-right.fa.fa-chevron-right aria-hidden='true'
//     //         span.sr-only Next
//     //       /! Indicators
//     //       ol.carousel-indicators
//     //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
//     //           li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
//     //     hr



//     // .col-12.col-sm-12.text-center
//     //   - if @arr_of_postgame_card_sets.blank?
//     //     h3.h3 No Games Have Been Played

//     //   - else
//     //     h3.h3.text-center All Games I've played
//     //     h6.h6.text-center.glow = "( Colored 'Created By' cards were made by you. )"
//     //     = render partial: 'shared/card_slideshow', locals: { arr_of_postgame_card_sets: @arr_of_postgame_card_sets}
// {/*}*/}




// // shared/card_slideshow.html.slim
// // / locals : { arr_of_postgame_card_sets: [ @game1.cards_from_finished_game (, ...)]  }
// //   / arr_of_postgame_card_sets :  [   [  [   [       [     ,      ] ], [  ] ] ]   ]
// //   /                              g  gu  c   g_u_n   card     c

// //   / The card.uploader_id compared to @current_user.id will reveal if current_user drew that card
// //   / have text glow if
// // .carousel-wrapper
// //   - arr_of_postgame_card_sets.each_with_index do |game_card_set, game_card_set_index|
// //     hr
// //     h3.h3.game-index-counter = "Game #{game_card_set_index + 1}"
// //     - game_card_set.each_with_index do |games_user, games_user_index|
// //       - unless games_user_index == 0
// //         hr.dotted-line

// //       - carousel_id = "carousel-#{games_user_index}"
// //       .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
// //         /! Indicators
// //         ol.carousel-indicators
// //           - games_user.each_with_index do |card_container, card_container_index|
// //             li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
// //         /! Wrapper for slides
// //         .carousel-inner
// //           - games_user.each_with_index do |card_container, card_container_index|
// //             .carousel-item.text-center class=(card_container_index == 0 ? 'active' : '')
// //               - if(card_container[1].drawing?)

// //                 img.d-block.text-center src=get_drawing_url(card_container[1]) alt='Drawing to Describe' style='max-width: 325px; max-height: 375px; margin: auto;'
// //                 / = image_tag get_drawing_url(card_container[1]), alt: "Drawing to describe", class: 'd-block'
// //               - elsif(card_container[1].description?)
// //                 h4.h4.description-text.text-center = card_container[1].description_text

// //               .carousel-caption.d-block
// //                 - did_i_make_card = card_container[1].uploader_id == @current_user.id
// //                 p.h4 class=(did_i_make_card ? 'glow': '') Created By:
// //                 p.h5 class=(did_i_make_card ? 'glow': '') = card_container[0]



// //         /! Controls
// //         a.carousel-control-prev data-slide='prev' href="##{carousel_id}" role='button'
// //           span.carousel-control-prev-icon aria-hidden="true"
// //           span.sr-only Previous

// //         a.carousel-control-next data-slide='next' href="##{carousel_id}" role='button'
// //           span.carousel-control-next-icon aria-hidden="true"
// //           span.sr-only Previous
