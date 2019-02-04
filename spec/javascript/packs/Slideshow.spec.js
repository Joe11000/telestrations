import React from 'react';
import { mount } from 'enzyme';
import Slideshow from 'packs/postgame/Slideshow';
import { finished } from 'stream';
var mock_games_index_request = require('../mock_games_index_request')

describe('Slideshow component', () => {
  describe('smoke test', () => {
    it('a carousel is on the screen', () => {
      const props = { deck: mock_games_index_request.arr_of_postgame_card_set[0], 
                      current_user_info: mock_games_index_request.current_user_info }
      const slideshow_component = mount(<Slideshow {...props} />);
    
      expect(slideshow_component.find('.carousel .carousel-indicators').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-control-prev').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-control-next').length).toEqual(1);
      expect(slideshow_component.find('.carousel .carousel-item').length).toEqual(3);

      
      // expect( slideshow_component.contains('.card-header .nav-item') ).to.have.lengthOf(2);
      // expect( slideshow_component.contains('.card-header .nav-item:eq(1)') ).to.eq.lengthOf(2);
      // expect( slideshow_component.children(CarouselItem) ).to.have.lengthOf(props.length);
    });

    it("current_user's card is glowing in each slideshow", () => {
      const props_1 = { deck: mock_games_index_request.arr_of_postgame_card_set[0], 
                        current_user_info: mock_games_index_request.current_user_info }
      const slideshow_component_1 = mount(<Slideshow {...props_1} />);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(true);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(false);
      expect(slideshow_component_1.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(false);

      const props_2 = { deck: mock_games_index_request.arr_of_postgame_card_set[1], 
                        current_user_info: mock_games_index_request.current_user_info }
      const slideshow_component_2 = mount(<Slideshow {...props_2} />);
      expect(slideshow_component_2.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(false);
      expect(slideshow_component_2.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(true);
      expect(slideshow_component_2.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(false);


      const props_3 = { deck: mock_games_index_request.arr_of_postgame_card_set[2], 
                        current_user_info: mock_games_index_request.current_user_info }
      const slideshow_component_3 = mount(<Slideshow {...props_3} />);
      expect(slideshow_component_3.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(false);
      expect(slideshow_component_3.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(false);
      expect(slideshow_component_3.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(true);
    });


    describe('first slideshow', () => {
      fit("first card has correct content", () => {
        const props_1 = { deck: mock_games_index_request.arr_of_postgame_card_set[0], 
          current_user_info: mock_games_index_request.current_user_info }
        const slideshow_component_1 = mount(<Slideshow {...props_1} />);
         
        card_1_body = slideshow_component_1.find('.carousel .carousel-item').at(0).find('.card-body p');
        const description = "excellent burnt orange tartan ham";
        const author = "By: Zackary Jaskolski";
        debugger
        expect(card_1_body.at(0))).toEqual(description);
        expect(card_1_body.at(1))).toEqual(author);
      });

      it('second card has correct content', () => {})

      it('third card has correct content', () => {});
    });
  })
});
