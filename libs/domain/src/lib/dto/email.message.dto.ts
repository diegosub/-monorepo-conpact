import { EmailTemplateDTO } from './email.template.dto';

export interface EmailMessageDTO {

  to: string;
  from?: string;
  cc?: string[];
  assunto?: string;
  texto?: string;
  template?: EmailTemplateDTO;
  anexos?: string[]

}
