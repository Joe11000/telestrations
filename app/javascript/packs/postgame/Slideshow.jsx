import React, { Component } from 'react';
import {
  Carousel,
  CarouselItem,
  CarouselControl,
  CarouselIndicators,
  CarouselCaption
} from 'reactstrap';

class Slideshow extends Component {
  constructor(props) {
    super(props);
    this.next = this.next.bind(this);
    this.previous = this.previous.bind(this);
    this.goToIndex = this.goToIndex.bind(this);
    debugger
    this.acquireCardInfoForCarousel = this.acquireCardInfoForCarousel.bind(this);

    const _carousel_card_info = this.acquireCardInfoForCarousel(this.props.deck)
    this.state = {
                   activeIndex: 0,
                   carousel_card_info: _carousel_card_info,
                 };
  }

  acquireCardInfoForCarousel(deck) {
    debugger
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

  next() {
    if (this.animating) return;
    const nextIndex = this.state.activeIndex === this.state.carousel_card_info.length - 1 ? 0 : this.state.activeIndex + 1;
    this.setState({ activeIndex: nextIndex });
  }

  previous() {
    if (this.animating) return;
    const nextIndex = this.state.activeIndex === 0 ? this.state.carousel_card_info.length - 1 : this.state.activeIndex - 1;
    this.setState({ activeIndex: nextIndex });
  }

  goToIndex(newIndex) {
    if (this.animating) return;
    this.setState({ activeIndex: newIndex });
  }

  render() {
    const { activeIndex } = this.state;
    
    const slides = this.state.carousel_card_info.map((item, slide_index) => {
      return (
          <CarouselItem
            key={ `${this.props.list_item_index}_${slide_index}_${item.src}` }
            >
            <div className='bg-dark' style={{"height": '300px'}} >
              {
                item.src && 
                <img className="d-block mx-auto h-100" src={item.src} alt={item.altText} /> 
              }
            </div>

            <CarouselCaption className="text-danger" captionText={item.caption} captionHeader={item.caption}  />
          </CarouselItem>
      );
    });

    return (
      
      <Carousel
        autoplay={false}
        activeIndex={activeIndex}
        next={this.next}
        previous={this.previous}
        interval={false}
      >
        <CarouselIndicators items={this.state.carousel_card_info} activeIndex={activeIndex} onClickHandler={this.goToIndex} />
        {slides}
        <CarouselControl direction="prev" directionText="Previous" onClickHandler={this.previous} />
        <CarouselControl direction="next" directionText="Next" onClickHandler={this.next} />
      </Carousel>
    );
  }
}

export default Slideshow;